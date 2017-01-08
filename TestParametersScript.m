% Execute ISS embed and extract process

%% Set path of images

    Output_Dir = 'Output/';

    if exist(Output_Dir, 'dir') ~= 7
        mkdir(Output_Dir);
    end
    
    InputImage_Name = 'airplane.bmp';

    InputImage_Dir = '';
    InputImage_Path = [InputImage_Dir InputImage_Name];
    
    tmp = strsplit(InputImage_Name, '.');
    filetype = tmp(end); filetype = filetype{1};
    filename = InputImage_Name(1:(length(InputImage_Name) - length(filetype) - 1));
	
    
	WMImage_Dir = Output_Dir;
    WMImage_Name = [filename '_watermarked.' filetype];
    WMImage_Path = [WMImage_Dir WMImage_Name];
	
	AttackedImage_Dir = Output_Dir;
	

%% ISSembed process	
	% Preprocessing - read original image
    orgImg = imread(InputImage_Path);
    subplot(1, 2, 1);
    imshow(orgImg);
    title('Original Image');

    
	
	% Prepoorcessing - generate watermark (n*1 +-1 vector)
    % n: watermark length, b: watermark
    n = 128*128;
    total_b = sign(randn(n, 1));
	

	% Watermark embedding settings - set alpha, lambda, blockSize, pattern
    % m: pattern length & x length
    alpha = 0.5;
    lambda = 1.00;
    blockSize = 8;
    m = 12;
    u = sign(randn(m, 1));
    
    % Print parameters
    fprintf('Parameters:\n');
    fprintf('\tWatermark length = %d\n', n);
    fprintf('\tPattern length = %d\n', m);
    fprintf('\tBlock size = %d\n', blockSize);
    fprintf('\tAlpha = %.2f\n', alpha);
    fprintf('\tLambda = %.2f\n', lambda);
	
    
    lowerbound = 4;
    upperbound = 512;
    offset = 1;
    
    num_test = (upperbound - lowerbound) / offset + 1;
    array_blockSize = zeros(1, num_test);
    array_capacity = zeros(1, num_test);
    array_psnr = zeros(1, num_test);
    array_ber = zeros(1, num_test);
    
    
    fprintf('Testing blockSize from %f to %f by %f:\n', lowerbound, upperbound, offset);
    
    i = 1;
    for blockSize_i = lowerbound: offset : upperbound
        
        fprintf('embedPos_i = %f\n', blockSize_i);
        
        n = floor(512/blockSize_i) * floor(512/blockSize_i);
        
        b = total_b(1: n);

        % Improved Spread Spectrum Embed
        watermarkedImg = ImprovedSpreadSpectrumEmbed(orgImg, b, u, alpha, lambda, blockSize_i);

        %subplot(1, 2, 2);
        %imshow(watermarkedImg, [0 255]);
        %title('Watermarked Image');

        % Save watermarked image
        %imwrite(watermarkedImg, WMImage_Path);
        
        
        
    %% ISSextract process
        % Watermark extraction settings - set pattern, blkSize, wmSize
        watermark0 = ImprovedSpreadSpectrumExtract(watermarkedImg, u, blockSize_i, n);


    %% Measurement

        %fprintf('Measurements:\n');

        % Measuring capacity
        capacity = n;
        fprintf('\tCapacity : %d\n', capacity);


        % Measuring fidelity
        PSNR = psnr(watermarkedImg, orgImg);
        fprintf('\tFidelity : PSNR = %f\n', PSNR);

        % Measuring robustness
        numDiff = sum((b == watermark0) == 0);
        BER = numDiff / n;
        fprintf('\tRobustness : BER = %.2f\n', BER);
        
        array_blockSize(i) = blockSize_i;
        array_capacity(i) = capacity;
        array_psnr(i) = PSNR;
        array_ber(i) = BER;
        
        
        i = i + 1;
    end
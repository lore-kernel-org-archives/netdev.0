From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] AX88796: ax_probe() fix irq assignment
Date: Tue, 21 Oct 2008 01:15:16 -0400
Message-ID: <48FD6564.8090104@garzik.org>
References: <48FD6C22.8030607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ben-linux@fluff.org, netdev@vger.kernel.org
To: roel kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53348 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751535AbYJUFPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 01:15:20 -0400
In-Reply-To: <48FD6C22.8030607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

roel kluin wrote:
> dev->irq is unsigned
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
> index 4207d6e..9a314d8 100644
> --- a/drivers/net/ax88796.c
> +++ b/drivers/net/ax88796.c
> @@ -838,12 +838,12 @@ static int ax_probe(struct platform_device *pdev)
>  
>  	/* find the platform resources */
>  
> -	dev->irq  = platform_get_irq(pdev, 0);
> -	if (dev->irq < 0) {
> +	ret  = platform_get_irq(pdev, 0);
> +	if (ret < 0) {
>  		dev_err(&pdev->dev, "no IRQ specified\n");
> -		ret = -ENXIO;
>  		goto exit_mem;
>  	}
> +	dev->irq = ret;

applied



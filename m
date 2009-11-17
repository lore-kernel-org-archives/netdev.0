From: David Woodhouse <david.woodhouse@intel.com>
Subject: Re: [patch 1/1] drivers/atm/solos-pci.c: fix warning/bug, clean up
 code
Date: Tue, 17 Nov 2009 22:55:55 +0000
Message-ID: <1258498555.6132.71.camel@macbook.infradead.org>
References: <200911172246.nAHMkiK2004221@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"chas@cmf.nrl.navy.mil" <chas@cmf.nrl.navy.mil>,
	"nathan@traverse.com.au" <nathan@traverse.com.au>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:25241 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756295AbZKQWzw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 17:55:52 -0500
In-Reply-To: <200911172246.nAHMkiK2004221@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-17 at 14:46 -0800, akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> drivers/atm/solos-pci.c: In function 'flash_upgrade':
> drivers/atm/solos-pci.c:528: warning: 'fw_name' may be used uninitialized in this function
> 
> Cc: Chas Williams <chas@cmf.nrl.navy.mil>
> Cc: Nathan Williams <nathan@traverse.com.au>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-By: David Woodhouse <David.Woodhouse@intel.com>

> ---
> 
>  drivers/atm/solos-pci.c |   29 ++++++++++++++++-------------
>  1 file changed, 16 insertions(+), 13 deletions(-)
> 
> diff -puN drivers/atm/solos-pci.c~drivers-atm-solos-pcic-fix-warning-bug-clean-up-code drivers/atm/solos-pci.c
> --- a/drivers/atm/solos-pci.c~drivers-atm-solos-pcic-fix-warning-bug-clean-up-code
> +++ a/drivers/atm/solos-pci.c
> @@ -531,34 +531,37 @@ static int flash_upgrade(struct solos_ca
>  	int numblocks = 0;
>  	int offset;
>  
> -	if (chip == 0) {
> +	switch (chip) {
> +	case 0:
>  		fw_name = "solos-FPGA.bin";
>  		blocksize = FPGA_BLOCK;
> -	} 
> -	
> -	if (chip == 1) {
> +		break;
> +	case 1:
>  		fw_name = "solos-Firmware.bin";
>  		blocksize = SOLOS_BLOCK;
> -	}
> -	
> -	if (chip == 2){
> +		break;
> +	case 2:
>  		if (card->fpga_version > LEGACY_BUFFERS){
>  			fw_name = "solos-db-FPGA.bin";
>  			blocksize = FPGA_BLOCK;
>  		} else {
> -			dev_info(&card->dev->dev, "FPGA version doesn't support daughter board upgrades\n");
> +			dev_info(&card->dev->dev, "FPGA version doesn't support"
> +					" daughter board upgrades\n");
>  			return -EPERM;
>  		}
> -	}
> -	
> -	if (chip == 3){
> +		break;
> +	case 3:
>  		if (card->fpga_version > LEGACY_BUFFERS){
>  			fw_name = "solos-Firmware.bin";
>  			blocksize = SOLOS_BLOCK;
>  		} else {
> -		dev_info(&card->dev->dev, "FPGA version doesn't support daughter board upgrades\n");
> -		return -EPERM;
> +			dev_info(&card->dev->dev, "FPGA version doesn't support"
> +					" daughter board upgrades\n");
> +			return -EPERM;
>  		}
> +		break;
> +	default:
> +		return -ENODEV;
>  	}
>  
>  	if (request_firmware(&fw, fw_name, &card->dev->dev))
> _



-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation


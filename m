From: Stephen Neuendorffer <stephen.neuendorffer@xilinx.com>
Subject: RE: [PATCH] Linux Device Driver for Xilinx LL TEMAC 10/100/1000 EthernetNIC
Date: Mon, 18 Aug 2008 10:01:41 -0700
Message-ID: <20080818170334.E5B99153006F@mail59-wa4.bigfish.com>
References: <48A7B01C.2070403@dlasys.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "David H. Lynch Jr." <dhlii@dlasys.net>,
	"linuxppc-embedded" <linuxppc-embedded@ozlabs.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-wa4.frontbridge.com ([216.32.181.16]:4880 "EHLO
	WA4EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752730AbYHRRDh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 13:03:37 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <48A7B01C.2070403@dlasys.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> +static struct platform_driver temac_device_driver = {
> +	.probe		= temac_device_probe,
> +	.remove		= __devexit_p(temac_device_remove),
> +	.suspend	= NULL,
> +	.resume		= NULL,
> +	.driver		= {
> +		.name	= DRV_NAME,
> +		.owner	= THIS_MODULE,
> +	},
> +};

I understand you're probably still using arch/ppc, but you'll need to
implement the of bindings as well.  This can be done relatively easily
in parallel with a platform_device binding. (and you can probably get
alot of the code out of the xilinx LLTEMAC driver.

> diff --git a/include/linux/xilinx_devices.h
b/include/linux/xilinx_devices.h
> index 41ad421..79ca491 100755
> --- a/include/linux/xilinx_devices.h
> +++ b/include/linux/xilinx_devices.h
> @@ -94,7 +94,7 @@ struct xtemac_platform_data {
>  #define XTEMAC_DMA_SGDMA	3	/* scatter gather DMA */
>  #endif
> 
> -#if defined(CONFIG_XILINX_LLTEMAC)
> +#if defined(CONFIG_XILINX_LLTEMAC) || defined(CONFIG_XPS_LLTEMAC)
>  /* LLTEMAC platform data */
>  struct xlltemac_platform_data {
>  	u8 tx_csum;

You probably want to generate patches against mainline in the future...

Steve

This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.



From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] smsc911x: add irq_flags in smsc911x_platform_config.
Date: Wed, 14 Jan 2009 17:06:33 +0000
Message-ID: <20090114170633.GG22976@n2100.arm.linux.org.uk>
References: <1231910512-8420-1-git-send-email-stanley.miao@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	linux-arm-kernel@lists.arm.linux.org.uk
To: "Stanley.Miao" <stanley.miao@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:33983 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764095AbZANRGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 12:06:47 -0500
Content-Disposition: inline
In-Reply-To: <1231910512-8420-1-git-send-email-stanley.miao@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 01:21:52PM +0800, Stanley.Miao wrote:
> When calling request IRQ it is desirable to allow platforms
> to specific flags for the call to request_irq. Adding irq_flags
> to smsc911x_platform_config allows these flags to be passed.
> 
> Signed-off-by: Stanley.Miao <stanley.miao@windriver.com>
> ---
>  drivers/net/smsc911x.c   |    6 ++++--
>  include/linux/smsc911x.h |    1 +
>  2 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> index f513bdf..1092517 100644
> --- a/drivers/net/smsc911x.c
> +++ b/drivers/net/smsc911x.c
> @@ -1896,6 +1896,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
>  	unsigned int intcfg = 0;
>  	int res_size;
>  	int retval;
> +	irq_flags;

This looks wrong.

>  	DECLARE_MAC_BUF(mac);
>  
>  	pr_info("%s: Driver version %s.\n", SMSC_CHIPNAME, SMSC_DRV_VERSION);
> @@ -1968,8 +1969,9 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
>  	smsc911x_reg_write(pdata, INT_EN, 0);
>  	smsc911x_reg_write(pdata, INT_STS, 0xFFFFFFFF);
>  
> -	retval = request_irq(dev->irq, smsc911x_irqhandler, IRQF_DISABLED,
> -			     dev->name, dev);
> +	irq_flags = IRQF_DISABLED | pdata->config.irq_flags;
> +	retval = request_irq(dev->irq, smsc911x_irqhandler, irq_flags,
> +				dev->name, dev);

If you need shared interrupt support, pass always pass IRQF_SHARED.
IRQF_SHARED and IRQF_DISABLED are a property of the driver.

Edge/level configuration should come from the struct resource.

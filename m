From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv2] smsc911x: add irq_flags in smsc911x_platform_config.
Date: Wed, 14 Jan 2009 17:07:31 +0000
Message-ID: <20090114170731.GH22976@n2100.arm.linux.org.uk>
References: <1231916280-7391-1-git-send-email-stanley.miao@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Steve.Glendinning@smsc.com,
	linux-arm-kernel@lists.arm.linux.org.uk
To: "Stanley.Miao" <stanley.miao@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:33987 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761765AbZANRHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 12:07:39 -0500
Content-Disposition: inline
In-Reply-To: <1231916280-7391-1-git-send-email-stanley.miao@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 02:58:00PM +0800, Stanley.Miao wrote:
> When calling request IRQ it is desirable to allow platforms
> to specific flags for the call to request_irq. Adding irq_flags
> to smsc911x_platform_config allows these flags to be passed.

Yay, it's finally come through.

> @@ -1968,8 +1969,9 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
>  	smsc911x_reg_write(pdata, INT_EN, 0);
>  	smsc911x_reg_write(pdata, INT_STS, 0xFFFFFFFF);
>  
> -	retval = request_irq(dev->irq, smsc911x_irqhandler, IRQF_DISABLED,
> -			     dev->name, dev);
> +	irq_flags = IRQF_DISABLED | pdata->config.irq_flags;
> +	retval = request_irq(dev->irq, smsc911x_irqhandler, irq_flags,
> +				dev->name, dev);

Same comments as for the other driver.

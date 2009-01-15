From: "stanley.miao" <stanley.miao@windriver.com>
Subject: Re: [PATCHv2] smsc911x: add irq_flags in smsc911x_platform_config.
Date: Thu, 15 Jan 2009 10:45:52 +0800
Message-ID: <1231987552.6810.18.camel@localhost>
References: <1231916280-7391-1-git-send-email-stanley.miao@windriver.com>
	 <20090114170731.GH22976@n2100.arm.linux.org.uk>
Reply-To: stanley.miao@windriver.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Steve.Glendinning@smsc.com,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38483 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765AbZAOChb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 21:37:31 -0500
In-Reply-To: <20090114170731.GH22976@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve sent another patch to replace this patch.

Stanley.

On Wed, 2009-01-14 at 17:07 +0000, Russell King - ARM Linux wrote:
> On Wed, Jan 14, 2009 at 02:58:00PM +0800, Stanley.Miao wrote:
> > When calling request IRQ it is desirable to allow platforms
> > to specific flags for the call to request_irq. Adding irq_flags
> > to smsc911x_platform_config allows these flags to be passed.
> 
> Yay, it's finally come through.
> 
> > @@ -1968,8 +1969,9 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
> >  	smsc911x_reg_write(pdata, INT_EN, 0);
> >  	smsc911x_reg_write(pdata, INT_STS, 0xFFFFFFFF);
> >  
> > -	retval = request_irq(dev->irq, smsc911x_irqhandler, IRQF_DISABLED,
> > -			     dev->name, dev);
> > +	irq_flags = IRQF_DISABLED | pdata->config.irq_flags;
> > +	retval = request_irq(dev->irq, smsc911x_irqhandler, irq_flags,
> > +				dev->name, dev);
> 
> Same comments as for the other driver.

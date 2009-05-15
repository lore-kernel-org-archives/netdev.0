From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2 5/7] [PATCH 5/8] can: SJA1000 generic platform bus
 driver
Date: Fri, 15 May 2009 11:33:08 +0200
Message-ID: <4A0D36D4.5040908@grandegger.com>
References: <20090512092757.048938233@denx.de>	<20090512092757.894204198@denx.de> <20090513160235.5d2d281c@bike.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Jonathan Corbet <corbet@lwn.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:54954 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757574AbZEOJdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 05:33:08 -0400
In-Reply-To: <20090513160235.5d2d281c@bike.lwn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Corbet wrote:
> On Tue, 12 May 2009 11:28:02 +0200
> Wolfgang Grandegger <wg@grandegger.com> wrote:
> 
>> This driver adds support for the SJA1000 chips connected to the
>> "platform bus", which can be found on various embedded systems.
> 
> [...]
> 
>> +
>> +static u8 sp_read_reg(const struct net_device *dev, int reg)
>> +{
>> +	return ioread8((void __iomem *)(dev->base_addr + reg));
>> +}
>> +
>> +static void sp_write_reg(const struct net_device *dev, int reg, u8 val)
>> +{
>> +	iowrite8(val, (void __iomem *)(dev->base_addr + reg));
>> +}
> 
> So there's no locking around accesses to the hardware at all.  How do you
> protect against concurrent access?

There is no concurrent access to the same register and PCI register
accesses do not need to be serialized.

> [...]
> 
>> +static int sp_remove(struct platform_device *pdev)
>> +{
>> +	struct net_device *dev = dev_get_drvdata(&pdev->dev);
>> +	struct resource *res;
>> +
>> +	unregister_sja1000dev(dev);
>> +	dev_set_drvdata(&pdev->dev, NULL);
>> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>> +	release_mem_region(res->start, res->end - res->start + 1);
>> +
>> +	if (dev->base_addr)
>> +		iounmap((void __iomem *)dev->base_addr);
> 
> Seems like you should unmap it before releasing it back to the kernel.
> Nobody else is ever going to jump in and try to map it, but still...

Will fix.

Wolfgang.



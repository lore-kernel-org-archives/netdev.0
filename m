From: Joe Perches <joe@perches.com>
Subject: RFC: Convert printks with net_device to dev_<level>
Date: Fri, 29 Jan 2010 12:01:26 -0800
Message-ID: <1264795286.25140.72.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1605 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754676Ab0A2UB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 15:01:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been playing with a cocci script and some additional
scripts to automate a conversion of printk and pr_<level>
logging messages with a reference to a struct net_device
to dev_<level>(&net_device->dev, ...)

A sample conversion:

-	printk(KERN_INFO "%s: Using MII transceiver %d, status %4.4x.\n",
-	       dev->name, tp->phys[0], tulip_mdio_read(dev, tp->phys[0], 1));
+	dev_info(&dev->dev, "Using MII transceiver %d, status %04x\n",
+		 tp->phys[0], tulip_mdio_read(dev, tp->phys[0], 1));

I submitted conversions for drivers/net/tulip/.
I did not convert any calls with KERN_DEBUG.
http://patchwork.ozlabs.org/patch/43889/

The logging messages are a bit more verbose/complete.
Code size increases a small amount.

Is this sort of conversion useful?
Should more conversions be submitted?
Would it be useful to convert the KERN_DEBUG calls?
Any automated conversion could use:

	printk(KERN_DEBUG "%s: ...", dev->name
	dev_printk(KERN_DEBUG, &dev->dev, "...


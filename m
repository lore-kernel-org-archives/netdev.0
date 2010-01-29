From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: RFC: Convert printks with net_device to dev_<level>
Date: Fri, 29 Jan 2010 20:25:07 +0000
Message-ID: <1264796707.2785.18.camel@achroite.uk.solarflarecom.com>
References: <1264795286.25140.72.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:4187 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754668Ab0A2UZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 15:25:10 -0500
In-Reply-To: <1264795286.25140.72.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-01-29 at 12:01 -0800, Joe Perches wrote:
> I've been playing with a cocci script and some additional
> scripts to automate a conversion of printk and pr_<level>
> logging messages with a reference to a struct net_device
> to dev_<level>(&net_device->dev, ...)
> 
> A sample conversion:
> 
> -	printk(KERN_INFO "%s: Using MII transceiver %d, status %4.4x.\n",
> -	       dev->name, tp->phys[0], tulip_mdio_read(dev, tp->phys[0], 1));
> +	dev_info(&dev->dev, "Using MII transceiver %d, status %04x\n",
> +		 tp->phys[0], tulip_mdio_read(dev, tp->phys[0], 1));
[...]

My understanding is that dev_* should be given a bus device (pci_device,
usb_device, ...), not a class device (net_device).  Of course, the net
device name is rather useful as well.  In sfc we print both once the net
device is registered.

It might be useful to add netdev_* print macros along the lines of:

#define netdev_name(dev)					\
	(((dev)->reg_state == NETREG_REGISTERED) ? (dev)->name : "")

#define netdev_info(dev, fmt, ...)				\
	dev_info((dev)->dev.parent, "%s " fmt, 			\
		 netdev_name(dev), __VA_ARGS__)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


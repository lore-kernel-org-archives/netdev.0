From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Issue with Micrel PCI Network Driver.
Date: Mon, 11 Feb 2013 17:47:03 +0000
Message-ID: <1360604823.2701.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <51158774.8080405@novatechweb.com>
	 <1360604764.2701.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <joseph.lutz@novatechweb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7638 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758096Ab3BKRrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 12:47:06 -0500
In-Reply-To: <1360604764.2701.10.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-11 at 17:46 +0000, Ben Hutchings wrote:
> On Fri, 2013-02-08 at 17:17 -0600, Joseph Lutz wrote:
> > I am having an issue with one of the network interface drivers. The 
> > driver in question is 'drivers/net/ethernet/micrel/ksz884x.c', the 
> > driver for the Micrel-Kendin device 8841.
> > I am trying to get systemd to rename the three network interfaces in my 
> > embedded atom system. I have one of the interfaces being renamed (an 
> > Intel Corporation 82574L), but the two Micrel interfaces are not being 
> > renamed. I traced this down to the driver not populating the 
> > /sys/devices/pci* information. Instead it places the driver into 
> > /sys/devices/virtual/net/.
> [...]
> 
> Right, this driver doesn't specify the parent device (PCI device) for
> the net devices it creates.
> 
> All you should need to is add:
> 	SET_NETDEV_DEV(dev, pdev);
> underneath the call to alloc_etherdev().

Or rather:
	SET_NETDEV_DEV(dev, &pdev->dev);

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

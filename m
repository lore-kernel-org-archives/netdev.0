From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: 802.1Q support?
Date: Mon, 19 Jan 2009 10:07:13 +0100
Message-ID: <20090119090713.GB17124@xi.wantstofly.org>
References: <200901121148.26905.rgetz@blackfin.uclinux.org> <200901130731.20538.rgetz@blackfin.uclinux.org> <200901131429.41178.florian@openwrt.org> <200901131154.07729.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
To: Robin Getz <rgetz@blackfin.uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:44977 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054AbZASJHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 04:07:15 -0500
Content-Disposition: inline
In-Reply-To: <200901131154.07729.rgetz@blackfin.uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2009 at 11:54:07AM -0500, Robin Getz wrote:

> > > Great - That looks like the way to go -- is there any plan in sending this
> > > to mainline?
> > 
> > Yes we will definitively submit it for mainline inclusion, Felix, who wrote 
> > the swconfig stuff will probably want to clean it up a bit and/or add 
> > features.
> > 
> > Lennert Buytenhek also proposed a Distributed Switch Architecture which is 
> > worth looking at, though it does not cover more "classical" switches 
> > connection over GPIO, SPI or special PHY address.
> 
> Hmmm ... 
> https://kerneltrap.org/mailarchive/linux-netdev/2008/9/25/3411164/thread
> 
> > The switch driver presents each port on the switch as a separate
> > network interface to Linux, polls the switch to maintain software
> > link state of those ports, forwards MII management interface
> > accesses to those network interfaces (e.g. as done by ethtool) to
> > the switch, and exposes the switch's hardware statistics counters
> > via the appropriate Linux kernel interfaces.
> 
> This exposes eth[n] for every port - and these are managed by the standard 
> userspace tools? 

Yep.  And the idea is that the HW switch chip will just follow the Linux
networking stack configuration, a la (ugly hack patch, but it shows the
idea):

	http://marc.info/?l=linux-netdev&m=123115178119072&w=2


> That seems like it would be more intuitive for end users -- wouldn't it?

Requiring special config tools is backwards, IMHO -- there should be no
difference for the end user between whether there is a hardware offload
present or not.

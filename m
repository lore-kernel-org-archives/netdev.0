From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: rtl8150: use default MTU of 1500
Date: Thu, 31 Jan 2008 17:05:01 +0100
Message-ID: <20080131160501.GA24019@xi.wantstofly.org>
References: <20080130193742.GA13631@xi.wantstofly.org> <alpine.DEB.1.00.0801311741400.4476@bender.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:57960 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764012AbYAaQFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 11:05:05 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0801311741400.4476@bender.nucleusys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2008 at 05:42:34PM +0200, Petko Manolov wrote:

> > The RTL8150 driver uses an MTU of 1540 by default, which causes a
> > bunch of problems -- it prevents booting from NFS root, for one.
> 
> Agreed, although it is a bit strange how this particular bug has
> sneaked up for so long...

I posted this patch sometime in 2006, and you asked me a question
about it then (why we don't just set RTL8150_MTU to 1500 -- the
answer would be that RTL8150_MTU is used in a couple more places
in the driver, including for allocing skbuffs), but I failed to
follow up to that question at the time, which is why I assume it got
dropped.

I have been carrying the patch in my own tree since then, and only
noticed recently that the patch never made it upstream.


cheers,
Lennert


> >Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
> >Cc: Petko Manolov <petkan@nucleusys.com>
> >
> >--- linux-2.6.24-git7.orig/drivers/net/usb/rtl8150.c	2008-01-24 
> >23:58:37.000000000 +0100
> >+++ linux-2.6.24-git7/drivers/net/usb/rtl8150.c	2008-01-30 
> >20:29:00.000000000 +0100
> >@@ -925,9 +925,8 @@
> >	netdev->hard_start_xmit = rtl8150_start_xmit;
> >	netdev->set_multicast_list = rtl8150_set_multicast;
> >	netdev->set_mac_address = rtl8150_set_mac_address;
> >	netdev->get_stats = rtl8150_netdev_stats;
> >-	netdev->mtu = RTL8150_MTU;
> >	SET_ETHTOOL_OPS(netdev, &ops);
> >	dev->intr_interval = 100;	/* 100ms */
> >
> >	if (!alloc_all_urbs(dev)) {
> >

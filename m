From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: netdevice: Kill 'feature' test macros.
Date: Tue, 12 Jul 2011 21:11:56 +0200
Message-ID: <201107122111.56365.arnd@arndb.de>
References: <20110712.105005.34046159802896038.davem@davemloft.net> <201107122106.21570.arnd@arndb.de> <20110712120923.e90730f8.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:61115 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251Ab1GLTMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 15:12:42 -0400
In-Reply-To: <20110712120923.e90730f8.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 12 July 2011 21:09:23 Randy Dunlap wrote:
> > 
> > I guess that's a good thing, but it also breaks these:
> > 
> > drivers/staging/wlags49_h2/wl_internal.h:#ifdef HAVE_NETDEV_PRIV
> > drivers/net/cxgb4vf/cxgb4vf_main.c:#ifdef HAVE_NET_DEVICE_OPS
> > drivers/staging/ft1000/ft1000-usb/ft1000_hw.c:#ifdef HAVE_NET_DEVICE_OPS
> > net/batman-adv/soft-interface.c:#ifdef HAVE_NET_DEVICE_OPS
> 
> Really?  I thought it would only break:
> 
> #if UNKNOWN_SYMBOL
> but not
> #ifdef UNKNOWN_SYMBOL

The point is that the drivers expect the symbol to be defined, e.g.

#ifdef HAVE_NETDEV_PRIV
#define wl_priv(dev) ((struct wl_private *) netdev_priv(dev))
#else
extern inline struct wl_private *wl_priv(struct net_device *dev)
{
    return dev->priv;
}
#endif

With current Linux versions, the first one is correct, the second one
is wrong, and removing the symbol changes which one is used.

	Arnd

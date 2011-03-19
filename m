From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [PATCH] net: drop NETIF_F_GSO from hw_features without
 NETIF_F_SG
Date: Sat, 19 Mar 2011 08:46:53 +0100
Message-ID: <20110319074653.GA12820@core.hellgate.ch>
References: <20110318195030.GA22350@core.hellgate.ch>
 <AANLkTim1_+GdURWxk=+N+5xCFTF1L27BD=+Uu+BY4jWF@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Micha? Miros?aw <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail13.bluewin.ch ([195.186.18.62]:27867 "EHLO
	mail13.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574Ab1CSHq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 03:46:56 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTim1_+GdURWxk=+N+5xCFTF1L27BD=+Uu+BY4jWF@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Mar 2011 21:43:23 +0100, Micha? Miros?aw wrote:
> 2011/3/18 Roger Luethi <rl@hellgate.ch>:
> > register_netdevice() removes NETIF_F_GSO from dev->features and
> > dev->wanted_features for hardware without NETIF_F_SG to "avoid warning from
> > netdev_fix_features()".
> >
> > However, as the flag remains set in dev->hw_features, users trying to
> > enable GSO via ethtool will still end up with NETIF_F_GSO stuck in
> > wanted_features, resulting in a warning every time they try to change any
> > feature (until they use ethtool to "disable" GSO):
> 
> That's expected, as it allows the user to debug why his request didn't
> work as expected. I think that those messages should get demoted to
> DEBUG if that's too noisy. The network core imposed conditions could
> be explained in Documentation/ or ethtool manpage instead.

I agree that it is good to have a note explaining what happened in the
kernel log, and the patch I posted does not do that; that is easy to fix.

However, I still think the current, unpatched behavior is confusing users.
ethtool_get_features() will happily tell the user that GSO is available for
a NIC even if it is not (because the NIC does not support SG). Then, if the
user tries to enable GSO, the operation fails silently: ethtool won't get
an error code, so it looks as if the operation succeeded. The user needs to
look into the kernel log or actually verify the offload settings to realize
that something went wrong.

Roger

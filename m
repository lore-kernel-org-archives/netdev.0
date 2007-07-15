From: David Miller <davem@davemloft.net>
Subject: Re: [NET 01/05]: Add net_device change_rx_mode callback
Date: Sat, 14 Jul 2007 18:51:44 -0700 (PDT)
Message-ID: <20070714.185144.97295326.davem@davemloft.net>
References: <20070712181338.13849.74894.sendpatchset@localhost.localdomain>
	<20070712181340.13849.14304.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50150
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765884AbXGOBvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 21:51:42 -0400
In-Reply-To: <20070712181340.13849.14304.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 12 Jul 2007 20:13:40 +0200 (MEST)

> [NET]: Add net_device change_rx_mode callback
> 
> Currently the set_multicast_list (and set_rx_mode) callbacks are
> responsible for configuring the device according to the IFF_PROMISC,
> IFF_MULTICAST and IFF_ALLMULTI flags and the mc_list (and uc_list in
> case of set_rx_mode).
> 
> These callbacks can be invoked from BH context without the rtnl_mutex
> by dev_mc_add/dev_mc_delete, which makes reading the device flags and
> promiscous/allmulti count racy. For real hardware drivers that just
> commit all changes to the hardware this is not a real problem since
> the stack guarantees to call them for every change, so at least the
> final call will not race and commit the correct configuration to the
> hardware.
> 
> For software devices that want to synchronize promiscous and multicast
> state to an underlying device however this can cause corruption of the
> underlying device's flags or promisc/allmulti counts.
> 
> When the software device is concurrently put in promiscous or allmulti
> mode while set_multicast_list is invoked from bottem half context, the
> device might synchronize the change to the underlying device without
> holding the rtnl_mutex, which races with concurrent changes to the
> underlying device.
> 
> Add a dev->change_rx_flags hook that is invoked when any of the flags
> that affect rx filtering change (under the rtnl_mutex), which allows
> drivers to perform synchronization immediately and only synchronize
> the address lists in set_multicast_list/set_rx_mode.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.

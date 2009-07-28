From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: shrink net_device by #ifdef-ing protocol-specific
 members
Date: Tue, 28 Jul 2009 09:49:15 -0700
Message-ID: <1248799755.6163.70.camel@Joe-Laptop.home>
References: <4A6DC314.2010303@ixiacom.com>
	 <20090727.082644.265102452.davem@davemloft.net>
	 <200907281743.27871.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, lgrijincu@ixiacom.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:1156 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbZG1QtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 12:49:19 -0400
In-Reply-To: <200907281743.27871.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-07-28 at 17:43 +0300, Octavian Purdila wrote:
> On Monday 27 July 2009 18:26:44 David Miller wrote:
> > From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
> > > Some members of net_device are used only by some protocols.
> > > If those protocols are not compiled (as modules or linked in) they
> > > should not take up space in the structure.
> > This benefits, at best, %0.000000001 of users of the Linux kernel,
> > because every distribution is going to turn on every single option.
> Not all Linux users are using regular (desktop/server) distributions. Linux is 
> used in embedded systems as well and in these case it makes sense to turn off 
> ax25/econet/decnet and in some cases even wireless/ipv6.
> > If you want to shrink structures, find ways to eliminate or
> > shrink structure members in all cases.
> We are looking into that as well since we have a pretty aggressive goal (get 
> net_device to 450 bytes or so), but we thought of starting with the low 
> hanging fruits. 
> Any suggestions in this area?

Some maybe not so good ones:

Perhaps:
	struct timer_list	watchdog_timer;
might become a
	struct timer_list	*watchdog_timer;

Maybe all the protocol/mac/bridge/vlan/garp/wireless specific
pointers might become a pointer to a list or array of pointers
allocated on demand.

Maybe combine perm_addr/broadcast/mc_list/uc addresses into a
single list with type information.  Maybe include dev_addrs,
but it's iterated with an rcu lock held.

Gaining less than 0, except maybe for weird network testing devices,
use a pointer to struct net_device_stats.



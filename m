From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] net: shrink net_device by #ifdef-ing protocol-specific members
Date: Wed, 29 Jul 2009 17:20:09 +0300
Message-ID: <200907291720.09704.opurdila@ixiacom.com>
References: <4A6DC314.2010303@ixiacom.com> <200907281743.27871.opurdila@ixiacom.com> <1248799755.6163.70.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, lgrijincu@ixiacom.com,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:14749 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752137AbZG2OWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 10:22:14 -0400
In-Reply-To: <1248799755.6163.70.camel@Joe-Laptop.home>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 28 July 2009 19:49:15 Joe Perches wrote:

> > We are looking into that as well since we have a pretty aggressive goal
> > (get net_device to 450 bytes or so), but we thought of starting with the
> > low hanging fruits.
> > Any suggestions in this area?
>
> Some maybe not so good ones:
>
> Perhaps:
> 	struct timer_list	watchdog_timer;
> might become a
> 	struct timer_list	*watchdog_timer;
>
> Maybe all the protocol/mac/bridge/vlan/garp/wireless specific
> pointers might become a pointer to a list or array of pointers
> allocated on demand.
>
> Maybe combine perm_addr/broadcast/mc_list/uc addresses into a
> single list with type information.  Maybe include dev_addrs,
> but it's iterated with an rcu lock held.
>
> Gaining less than 0, except maybe for weird network testing devices,
> use a pointer to struct net_device_stats.

Thanks for the suggestions.

BTW, we've noticed that the biggest net_device consumer is struct device with 
176 bytes consumed on our arch (powerpc) and the only things that are used 
from it seems to be the numa node id and the driver name. Some drivers also 
use it but most of the usage seems to be related to sysfs.

Do you think its worth trying to make dev dependent on CONFIG_SYSFS?

tavi


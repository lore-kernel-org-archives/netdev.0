From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH 0/2] Fix nh_saddr caching.
Date: Sat, 26 Mar 2011 01:30:18 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103260127230.1648@ja.ssi.bg>
References: <20110324.181413.173844730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53870 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395Ab1CYXYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2011 19:24:50 -0400
In-Reply-To: <20110324.181413.173844730.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Thu, 24 Mar 2011, David Miller wrote:

> Julian, the following two patches should take all of the
> issues we discovered the other week wrt. nh_saddr caching.
>
> First, we use a generation ID to invalidate cache nh_saddr
> settings any time a device goes up or an IP address is
> added/removed.
>
> Second, we move fa_scope up to fib_info->fib_scope, so that
> we always use the correct scope when computing the cached
> nh_saddr.
>
> Please review this carefully as this is delicate code.

 	Looks very good. I checked the tree to make sure that
FIB_RES_PREFSRC, FIB_RES_DEV and fib_info_update_nh_saddr are
called only for res after successful fib_lookup. Even
fib_create_info calls fib_info_update_nh_saddr at a place
where nh_dev != NULL.

 	Only one thing: as the preferred addresses can be used
even if they are configured on downed interface there is no
gain to increase dev_addr_genid in fib_netdev_event(). If there are
address changes while some device is down all nh_saddr_genid
values for the downed device will be outdated because there is
no traffic that can refresh the nh_saddr.

 	Tests revealed unrelated problem in fib_trie, preparing
separate patch...

Regards

--
Julian Anastasov <ja@ssi.bg>

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: don't call fib6_run_gc() until routing is
 ready
Date: Wed, 11 Sep 2013 17:05:11 -0400 (EDT)
Message-ID: <20130911.170511.2007837663367937795.davem@davemloft.net>
References: <20130909.132720.1372904024173191622.davem@davemloft.net>
	<20130909194504.1C691E5E72@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754640Ab3IKVFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 17:05:14 -0400
In-Reply-To: <20130909194504.1C691E5E72@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Mon,  9 Sep 2013 21:45:04 +0200 (CEST)

> When loading the ipv6 module, ndisc_init() is called before
> ip6_route_init(). As the former registers a handler calling
> fib6_run_gc(), this opens a window to run the garbage collector
> before necessary data structures are initialized. If a network
> device is initialized in this window, adding MAC address to it
> triggers a NETDEV_CHANGEADDR event, leading to a crash in
> fib6_clean_all().
> 
> Take the event handler registration out of ndisc_init() into a
> separate function ndisc_late_init() and move it after
> ip6_route_init().
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Looks good, applied, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 2/2] ipv6: fix ECMP route replacement
Date: Tue, 19 May 2015 16:51:03 -0400 (EDT)
Message-ID: <20150519.165103.1598743813050681946.davem@davemloft.net>
References: <cover.1431974706.git.mkubecek@suse.cz>
	<239760fdec3e503029fae3e5bb9d4eb3c4c33c20.1431974706.git.mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	roopa@cumulusnetworks.com
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48071 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbbESUvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:51:06 -0400
In-Reply-To: <239760fdec3e503029fae3e5bb9d4eb3c4c33c20.1431974706.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Mon, 18 May 2015 20:54:00 +0200 (CEST)

> When replacing an IPv6 multipath route with "ip route replace", i.e.
> NLM_F_CREATE | NLM_F_REPLACE, fib6_add_rt2node() replaces only first
> matching route without fixing its siblings, resulting in corrupted
> siblings linked list; removing one of the siblings can then end in an
> infinite loop.
> 
> IPv6 ECMP implementation is a bit different from IPv4 so that route
> replacement cannot work in exactly the same way. This should be a
> reasonable approximation:
> 
> 1. If the new route is ECMP-able and there is a matching ECMP-able one
> already, replace it and all its siblings (if any).
> 
> 2. If the new route is ECMP-able and no matching ECMP-able route exists,
> replace first matching non-ECMP-able (if any) or just add the new one.
> 
> 3. If the new route is not ECMP-able, replace first matching
> non-ECMP-able route (if any) or add the new route.
> 
> We also need to remove the NLM_F_REPLACE flag after replacing old
> route(s) by first nexthop of an ECMP route so that each subsequent
> nexthop does not replace previous one.
> 
> Fixes: 51ebd3181572 ("ipv6: add support of equal cost multipath (ECMP)")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Can I get some reviews please from interested parties?

As far as I can tell, this faithfully implements the policy we decided
upon at the end of the previous thread for this patch.  But I could be
wrong :-)

Thanks.

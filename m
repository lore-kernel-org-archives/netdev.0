From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: move rt_genid to different cache line
Date: Fri, 03 Jan 2014 19:48:11 -0500 (EST)
Message-ID: <20140103.194811.1577005821228999480.davem@davemloft.net>
References: <alpine.DEB.2.02.1401021155330.32674@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35453 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401AbaADAsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 19:48:13 -0500
In-Reply-To: <alpine.DEB.2.02.1401021155330.32674@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 2 Jan 2014 12:00:23 -0800 (PST)

> Running a simple netperf TCP_RR test with 200 clients shows that
> ipv4_dst_check is high on the list of functions in 'perf top'. The
> pertinent action in this function is in the call to rt_is_expired
> which checks the route genid (rt->rt_gentid) against the global value.
> rt_genid is in the same cacheline as dst->__refcnt which is causing
> false sharing.
> 
> This fix moves rt_genid into the first cacheline of the dst structure.
> The dst structue is explicitly packed for cacheline optimization, so to
> make room for the genid, I moved xfrm to cacheline with __refcnt (under
> the assumption it is less likely to be in the critical path).
> 
> I don't believe there is an issue in ip6_dst_check since rt6i_genid
> and the dst are in separate cachelines already (struct rt6_info).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Can you just put the genid deeper into "struct rtable" to solve this?

It might work well to put it next to the uncached list.

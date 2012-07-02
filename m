From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] rtcache remove respin
Date: Mon, 02 Jul 2012 03:59:17 -0700 (PDT)
Message-ID: <20120702.035917.541700718895213946.davem@davemloft.net>
References: <20120701.050243.908285695895815999.davem@davemloft.net>
	<1341225841.5269.69.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932365Ab2GBK7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 06:59:20 -0400
In-Reply-To: <1341225841.5269.69.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Jul 2012 12:44:01 +0200

> On Sun, 2012-07-01 at 05:02 -0700, David Miller wrote:
>> It's been a while and there were of course a lot of merge hassles with
>> the most recent set I posted, so I respun these patches tonight
>> because I wanted to see the effects of the recent rpfilter hacks on an
>> rtcache-less system.
>> 
>> On a SPARC T3-1:
>> 
>> 1) Output route lookup: ~2800 cycles
>> 2) Input route lookups: ~3000 cycles (rpfilter=0)
>>                         ~4300 cycles (rpfilter=1)
>> 
>> Another nice part is how small struct rtable is after this patch set:
>> 
>> struct rtable {
>> 	struct dst_entry        dst;
>> 	int                     rt_genid;
>> 	unsigned int            rt_flags;
>> 	__u16                   rt_type;
>> 	__be32                  rt_dst;
>> 	int                     rt_route_iif;
>> 	int                     rt_iif;
>> 	int                     rt_oif;
>> 	__be32                  rt_gateway;
>> 	u32                     rt_peer_genid;
>> 	unsigned long           _peer;
>> 	struct fib_info         *fi;
>> };
>> 
>> which is about 208 bytes on sparc64.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Can be <= 192 actually
> 
> rcu_head not needed anymore in dst_entry
> 
> If we still want __refcnt being on cache line boundary, we might find a
> better way to accomplish this.

Once we can actually check something like this in, rt_dst is
guarenteed to be eliminated as well.

The dst neighbour pointer will also be gone.

So lots of shrinking still to go and yes we'll need to reposition
that __refcnt member carefully.

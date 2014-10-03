From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qdisc: validate skb without holding lock
Date: Fri, 03 Oct 2014 15:36:45 -0700 (PDT)
Message-ID: <20141003.153645.72976986956341944.davem@davemloft.net>
References: <20141003.145647.1980640682969765484.davem@davemloft.net>
	<1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org, therbert@google.com,
	hannes@stressinduktion.org, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60360 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089AbaJCWel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:34:41 -0400
In-Reply-To: <1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Oct 2014 15:31:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Validation of skb can be pretty expensive :
> 
> GSO segmentation and/or checksum computations.
> 
> We can do this without holding qdisc lock, so that other cpus
> can queue additional packets.
> 
> Trick is that requeued packets were already validated, so we carry
> a boolean so that sch_direct_xmit() can validate a fresh skb list,
> or directly use an old one.
> 
> Tested on 40Gb NIC (8 TX queues) and 200 concurrent flows, 48 threads
> host.
> 
> Turning TSO on or off had no effect on throughput, only few more cpu
> cycles. Lock contention on qdisc lock disappeared.
> 
> Same if disabling TX checksum offload.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric!

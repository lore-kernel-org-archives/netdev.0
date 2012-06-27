From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid tx starvation by SYNACK packets
Date: Wed, 27 Jun 2012 09:54:30 +0200
Message-ID: <1340783670.2028.141.camel@localhost>
References: <201206260734.33472.hans.schillstrom@ericsson.com>
	 <1340730156.10893.359.camel@edumazet-glaptop>
	 <1340778733.2028.110.camel@localhost>
	 <20120626.235423.588696200884989114.davem@davemloft.net>
	 <1340781845.2028.133.camel@localhost>
	 <1340782216.10893.427.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hans.schillstrom@ericsson.com,
	subramanian.vijay@gmail.com, dave.taht@gmail.com,
	netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	mph@hoth.dk
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22603 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756374Ab2F0Hyn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 03:54:43 -0400
In-Reply-To: <1340782216.10893.427.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 09:30 +0200, Eric Dumazet wrote:
> On Wed, 2012-06-27 at 09:24 +0200, Jesper Dangaard Brouer wrote:
> 
> > But, I still believe that we need, to solve this SYN issues by parallel
> > processing of packets. (It seems Eric and Hans are looking at a single
> > core SYN processing scheme, but I might have missed their point).
> 
> Yep
> 
> Parallel processing will only benefit multiqueue setups.
> 
> Many linux servers in colocations are still using a mono queue NIC, and
> default linux configuration is to use a single cpu to handle all
> incoming frames (no RPS/RFS).

I see, your target is different than mine (now I understand you
motivation).  Its good, as optimizing the single queue case, would also
be a benefit once we implement parallel processing / take advantage of
the multi queue devices.


> Sometime the hw IRQ itself is distributed among several cpus, but at one
> single moment, only one cpu is serving the NAPI poll.
> 
> As long as the LISTEN processing is locking the socket, there is no
> point distributing SYN packets to multiple cpus, this only adds
> contention and poor performance because of false sharing.
> 
> My plan is to get rid of the socket lock for LISTEN and use RCU instead.

Well, that would lead to parallel SYN processing, wouldn't it?

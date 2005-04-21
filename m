From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netem: account for packets in delayed queue in qlen
Date: Fri, 22 Apr 2005 01:39:32 +0200
Message-ID: <426839B4.2090502@trash.net>
References: <20050329152110.38d50653@dxpl.pdx.osdl.net>	<4252EB9D.9070305@trash.net>	<20050407120417.4297cd14@dxpl.pdx.osdl.net>	<42628300.9010007@trash.net>	<20050419110639.47767113@localhost.localdomain>	<42666098.5060409@trash.net>	<20050421132020.41858bc4@localhost.localdomain>	<426832E1.7020003@trash.net> <20050422092221.4950e23c@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050422092221.4950e23c@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I'm thinking of changing enqueue (and maybe later dequeue) API to decouple
> the qlen assumption.
> 
> Either:
> 	rc = qdisc->enqueue(skb, qdisc, &my->qlen)
> or add NET_XMIT_DUPPED
> 	rc = qdisc->enqueue(skb, qdisc);
> 	if (rc < NET_XMIT_SUCCESS) {
> 		++my->dropped;
> 	} else {
> 		my->qlen++;
> 		if (rc == NET_XMIT_DUPPED)
> 			my->qlen++;
> }

To be frank, I don't like either one. Both have the same problem
wrt. HFSC, the first solution requires changes all over the place,
the second one is unflexible and also requires lots of changes. I
don't see what could benefit from this API change besides netem,
so I'd vote to go with my proposed solution: store the parent
pointers in struct Qdisc, add code to walk up the tree and adjust
the qlen to netem, and fix up HFSC.

Regards
Patrick

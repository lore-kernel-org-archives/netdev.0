From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
 length for qdiscs
Date: Fri, 25 Jul 2008 04:52:15 -0700 (PDT)
Message-ID: <20080725.045215.10253476.davem@davemloft.net>
References: <20080725.035712.33516738.davem@davemloft.net>
	<20080725113757.GC10399@ff.dom.local>
	<20080725115355.GD10399@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60387
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752799AbYGYLwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 07:52:16 -0400
In-Reply-To: <20080725115355.GD10399@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 25 Jul 2008 11:53:55 +0000

> On Fri, Jul 25, 2008 at 11:37:57AM +0000, Jarek Poplawski wrote:
>
> As a matter of fact it's a good example: in your patch we have this:
> 
> +		ret = cl->un.leaf.q->enqueue(skb, cl->un.leaf.q);
> +		if (ret == NET_XMIT_DROP) {
> +			sch->qstats.drops++;
> +			cl->qstats.drops++;
> +		} else {
> +			cl->bstats.packets +=
> +				skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
> +			cl->bstats.bytes += skb->len;
> 
> So, if something works like noop_enqueue() and returns NET_XMIT_CN
> here, we're just using skb after kfree...

noop_enqueue() can only be a root qdisc, never a leaf hanging off of a
class

What TCP depends upon is that DROP means DROP, and that the
packet never reached the device and has been freed.

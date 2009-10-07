From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening
 sockets, and for IPv4 multicast forwarding
Date: Wed, 07 Oct 2009 03:19:57 -0700 (PDT)
Message-ID: <20091007.031957.197632672.davem@davemloft.net>
References: <200910051646.34770.atis@mikrotik.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, panther@balabit.hu, eric.dumazet@gmail.com,
	brian.haley@hp.com, zenczykowski@gmail.com
To: atis@mikrotik.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40798
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757916AbZJGKUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 06:20:02 -0400
In-Reply-To: <200910051646.34770.atis@mikrotik.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atis Elsts <atis@mikrotik.com>
Date: Mon, 5 Oct 2009 16:46:34 +0300

> @@ -1238,6 +1238,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
>  
>  	if (vif->flags&VIFF_TUNNEL) {
>  		struct flowi fl = { .oif = vif->link,
> +				    .mark = skb->mark,
>  				    .nl_u = { .ip4_u =
>  					      { .daddr = vif->remote,
>  						.saddr = vif->local,

I'm not so sure if this is right.

I understand what you're trying to do, inherit the socket's
mark when it goes over a multicast tunnel.

But I'm not so sure that's what we want to do, semantically.

Could you split out these skb->mark cases into a seperate
patch?  The parts that only use sk->mark are fine and I
would like to apply a patch from you which just does that
while we discuss the skb->mark case.

Thanks.

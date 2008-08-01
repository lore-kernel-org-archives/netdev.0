From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net_sched: Add qdisc __NET_XMIT_STOLEN flag
Date: Fri, 01 Aug 2008 08:15:50 +0200
Message-ID: <4892AA16.40706@trash.net>
References: <20080731171431.GA9464@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63541 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbYHAGPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 02:15:53 -0400
In-Reply-To: <20080731171431.GA9464@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Hi,
> 
> Here is a complete, I hope,  version of the patch to not linger this
> all to much, but of course any redoing is possible.

This looks good to me. Just one suggestion:

> +#ifdef CONFIG_NET_CLS_ACT
> +/* additional qdisc xmit flags */
> +enum net_xmit_qdisc_t {
> +	__NET_XMIT_STOLEN = NET_XMIT_MASK + 1,
> +};
> +
> +#define net_xmit_drop_count(e)	((e) & __NET_XMIT_STOLEN ? 0 : 1)
> +
> +#else
> +#define net_xmit_drop_count(e)	(1)
> +#endif
> +
>  static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  {
>  #ifdef CONFIG_NET_SCHED
> @@ -343,7 +355,7 @@ static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
>  {
>  	qdisc_skb_cb(skb)->pkt_len = skb->len;
> -	return qdisc_enqueue(skb, sch);
> +	return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;

It would be nice to handle NET_XMIT_BYPASS similar, currently its
mapped to NET_XMIT_SUCCESS by dev_queue_xmit(). Simply adding it
to net_xmit_qdisc_t as

__NET_XMIT_BYPASS = NET_XMIT_MASK + 0x2

and removing the mapping from dev_queue_xmit() should work I think.

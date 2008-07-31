From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net-sched: add packet length pointer parameter for	qdisc_enqueue
Date: Thu, 31 Jul 2008 10:11:24 +0800
Message-ID: <E1KONdU-00015S-00@gondolin.me.apana.org.au>
References: <20080730185542.23727.5949.stgit@fate.lan>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: jussi.kivilinna@mbnet.fi (Jussi Kivilinna)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47034 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752680AbYGaCLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 22:11:34 -0400
In-Reply-To: <20080730185542.23727.5949.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna <jussi.kivilinna@mbnet.fi> wrote:
>
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index b5f40d7..a428b93 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -331,19 +331,22 @@ static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
>        return qdisc_skb_cb(skb)->pkt_len;
> }
> 
> -static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> +static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch,
> +                               unsigned int *pkt_len)
> {
> #ifdef CONFIG_NET_SCHED
>        if (sch->stab)
>                qdisc_calculate_pkt_len(skb, sch->stab);
> #endif
> +       if (likely(pkt_len != NULL))
> +               *pkt_len = qdisc_pkt_len(skb);

Icky! Why can't you do this in the caller instead? Calculating
the packet length isn't related to the act of enqueueing.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

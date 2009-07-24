From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Fri, 24 Jul 2009 14:46:06 +0200
Message-ID: <4A69AD0E.4020701@cosmosbay.com>
References: <20090720074607.32463.23013.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, Jarek Poplawski <jarkao2@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42335 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbZGXMqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 08:46:23 -0400
In-Reply-To: <20090720074607.32463.23013.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar a =E9crit :
> From: Krishna Kumar <krkumar2@in.ibm.com>
> diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
> --- org/net/sched/sch_generic.c	2009-05-25 07:48:07.000000000 +0530
> +++ new/net/sched/sch_generic.c	2009-07-20 13:09:18.000000000 +0530
> @@ -56,12 +56,8 @@ static inline struct sk_buff *dequeue_sk
>  	struct sk_buff *skb =3D q->gso_skb;
> =20
>  	if (unlikely(skb)) {
> -		struct net_device *dev =3D qdisc_dev(q);
> -		struct netdev_queue *txq;
> -
>  		/* check the reason of requeuing without tx lock first */
> -		txq =3D netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> -		if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
> +		if (!netif_tx_queue_frozen(q->dev_queue))
>  			q->gso_skb =3D NULL;

This part might be a separate patch...

Are we sure these are equivalent ?

OLD)
	struct net_device *dev =3D qdisc_dev(q);
	struct netdev_queue *txq;
	txq =3D netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));

NEW)
	struct netdev_queue *txq =3D q->dev_queue;


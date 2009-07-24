From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Fri, 24 Jul 2009 22:54:07 +0800
Message-ID: <20090724145407.GA25861@gondor.apana.org.au>
References: <20090720074607.32463.23013.sendpatchset@localhost.localdomain> <4A69AD0E.4020701@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Krishna Kumar <krkumar2@in.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Jarek Poplawski <jarkao2@gmail.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47730 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751362AbZGXOyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 10:54:24 -0400
Content-Disposition: inline
In-Reply-To: <4A69AD0E.4020701@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 24, 2009 at 02:46:06PM +0200, Eric Dumazet wrote:
> Krishna Kumar a =E9crit :
> > From: Krishna Kumar <krkumar2@in.ibm.com>
> > diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
> > --- org/net/sched/sch_generic.c	2009-05-25 07:48:07.000000000 +0530
> > +++ new/net/sched/sch_generic.c	2009-07-20 13:09:18.000000000 +0530
> > @@ -56,12 +56,8 @@ static inline struct sk_buff *dequeue_sk
> >  	struct sk_buff *skb =3D q->gso_skb;
> > =20
> >  	if (unlikely(skb)) {
> > -		struct net_device *dev =3D qdisc_dev(q);
> > -		struct netdev_queue *txq;
> > -
> >  		/* check the reason of requeuing without tx lock first */
> > -		txq =3D netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
> > -		if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
> > +		if (!netif_tx_queue_frozen(q->dev_queue))
> >  			q->gso_skb =3D NULL;
>=20
> This part might be a separate patch...
>=20
> Are we sure these are equivalent ?

I think the only thing that can change this is act_skbedit.  But
really any queue that changes the skb queue mapping should physically
move the packet to that qdisc.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

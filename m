From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 6/8] net: mv643xx_eth: Limit the TSO segments and adjust
 stop/wake thresholds
Date: Fri, 30 May 2014 15:08:39 -0300
Message-ID: <20140530180839.GA12172@arch.cereza>
References: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1401468011-10609-7-git-send-email-ezequiel.garcia@free-electrons.com>
 <1401470493.3645.129.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>, fugang.duan@freescale.com,
	Willy Tarreau <w@1wt.eu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:59040 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933525AbaE3SJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 14:09:22 -0400
Content-Disposition: inline
In-Reply-To: <1401470493.3645.129.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On 30 May 10:21 AM, Eric Dumazet wrote:
> On Fri, 2014-05-30 at 13:40 -0300, Ezequiel Garcia wrote:
> > =20
> > -static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *sk=
b)
> > +static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *sk=
b,
> > +			  struct net_device *dev)
> >  {
> >  	struct mv643xx_eth_private *mp =3D txq_to_mp(txq);
> >  	int nr_frags =3D skb_shinfo(skb)->nr_frags;
> > @@ -910,11 +918,15 @@ static int txq_submit_skb(struct tx_queue *tx=
q, struct sk_buff *skb)
> >  	cmd_sts =3D 0;
> >  	l4i_chk =3D 0;
> > =20
> > +	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {
>=20
> I am not sure I understand this part.
>=20
> You have one skb here, so why are you using MAX_SKB_FRAGS ?
>=20

This check was moved around, so I'm blindly carrying it over.
You meant that I can directly use skb_shinfo(skb)->nr_frags, right?

> > +		if (net_ratelimit())
> > +			netdev_err(dev, "tx queue full?!\n");
> > +		return -EBUSY;
> > +	}
> > +
>=20
> Also it looks like this part will become dead after the following
> patch...
>=20

Indeed, I've kept it just for consistency. I had to return some error v=
alue
and EBUSY seems the most appropriate. Do you think I should change this=
?

Thanks for the feedback,
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com

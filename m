From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH v2] slip: Use net_device_stats from struct net_device
Date: Thu, 26 Aug 2010 11:18:00 +0200
Message-ID: <20100826091800.GI20793@distanz.ch>
References: <1282206313-10667-1-git-send-email-tklauser@distanz.ch> <1282811286-19659-1-git-send-email-tklauser@distanz.ch> <1282811972.2476.146.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from symlink.to.noone.org ([85.10.207.172]:53330 "EHLO sym.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752304Ab0HZJSD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 05:18:03 -0400
Content-Disposition: inline
In-Reply-To: <1282811972.2476.146.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-08-26 at 10:39:32 +0200, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 26 ao=FBt 2010 =E0 10:28 +0200, Tobias Klauser a =E9crit :
> > @@ -562,12 +563,12 @@ static struct net_device_stats *
> >  sl_get_stats(struct net_device *dev)
> >  {
> >  	struct net_device_stats *stats =3D &dev->stats;
> > -	struct slip *sl =3D netdev_priv(dev);
> > -	unsigned long c_rx_dropped =3D 0;
> >  #ifdef SL_INCLUDE_CSLIP
> > +	unsigned long c_rx_dropped =3D 0;
> >  	unsigned long c_rx_fifo_errors =3D 0;
> >  	unsigned long c_tx_fifo_errors =3D 0;
> >  	unsigned long c_collisions =3D 0;
> > +	struct slip *sl =3D netdev_priv(dev);
> >  	struct slcompress *comp =3D sl->slcomp;
> > =20
> >  	if (comp) {
> > @@ -579,17 +580,9 @@ sl_get_stats(struct net_device *dev)
> >  	stats->rx_fifo_errors =3D sl->rx_compressed + c_rx_fifo_errors;
> >  	stats->tx_fifo_errors =3D sl->tx_compressed + c_tx_fifo_errors;
> >  	stats->collisions     =3D sl->tx_misses + c_collisions;
> > +	stats->rx_dropped    +=3D c_rx_dropped;
>=20
> Sorry this bit is wrong.
>=20
> You cannot do "stats->somefield +=3D somevalue", since its cumulative=
 for
> each call to "cat /proc/net/dev"

Sorry for getting it wrong the second time and wasting your time. I
didn't read your answer to the first patch careful enough (I should hav=
e
used ndo_get_stats64 as you clearly stated). Hopefully I get it right i=
n
v3 :-)

Sorry again and thanks a lot

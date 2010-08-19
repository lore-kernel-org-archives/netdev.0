From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] slip: Use net_device_stats from struct net_device
Date: Thu, 19 Aug 2010 11:12:52 +0200
Message-ID: <20100819091252.GB20793@distanz.ch>
References: <1282206313-10667-1-git-send-email-tklauser@distanz.ch> <1282207791.2549.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from symlink.to.noone.org ([85.10.207.172]:58914 "EHLO sym.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751315Ab0HSJNA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 05:13:00 -0400
Content-Disposition: inline
In-Reply-To: <1282207791.2549.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-08-19 at 10:49:51 +0200, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 19 ao=FBt 2010 =E0 10:25 +0200, Tobias Klauser a =E9crit :
> > Use net_device->stats for stats instead of private variable copies =
in
> > struct slip.
> >=20
> > Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> > ---
> >  drivers/net/slip.c |   64 ++++++++++++++++++++++------------------=
------------
> >  drivers/net/slip.h |    9 -------
> >  2 files changed, 27 insertions(+), 46 deletions(-)
>=20
>=20
> > @@ -561,36 +562,25 @@ static int sl_change_mtu(struct net_device *d=
ev, int new_mtu)
> >  static struct net_device_stats *
> >  sl_get_stats(struct net_device *dev)
> >  {
> > -	static struct net_device_stats stats;
> > +	struct net_device_stats *stats =3D &dev->stats;
> >  	struct slip *sl =3D netdev_priv(dev);
> >  #ifdef SL_INCLUDE_CSLIP
> >  	struct slcompress *comp;
> >  #endif
> > =20
> > -	memset(&stats, 0, sizeof(struct net_device_stats));
> > -
> > -	stats.rx_packets     =3D sl->rx_packets;
> > -	stats.tx_packets     =3D sl->tx_packets;
> > -	stats.rx_bytes	     =3D sl->rx_bytes;
> > -	stats.tx_bytes	     =3D sl->tx_bytes;
> > -	stats.rx_dropped     =3D sl->rx_dropped;
> > -	stats.tx_dropped     =3D sl->tx_dropped;
> > -	stats.tx_errors      =3D sl->tx_errors;
> > -	stats.rx_errors      =3D sl->rx_errors;
> > -	stats.rx_over_errors =3D sl->rx_over_errors;
> >  #ifdef SL_INCLUDE_CSLIP
> > -	stats.rx_fifo_errors =3D sl->rx_compressed;
> > -	stats.tx_fifo_errors =3D sl->tx_compressed;
> > -	stats.collisions     =3D sl->tx_misses;
> > +	stats->rx_fifo_errors =3D sl->rx_compressed;
> > +	stats->tx_fifo_errors =3D sl->tx_compressed;
> > +	stats->collisions     =3D sl->tx_misses;
> >  	comp =3D sl->slcomp;
> >  	if (comp) {
> > -		stats.rx_fifo_errors +=3D comp->sls_i_compressed;
> > -		stats.rx_dropped     +=3D comp->sls_i_tossed;
> > -		stats.tx_fifo_errors +=3D comp->sls_o_compressed;
> > -		stats.collisions     +=3D comp->sls_o_misses;
> > +		stats->rx_fifo_errors +=3D comp->sls_i_compressed;
> > +		stats->rx_dropped     +=3D comp->sls_i_tossed;
> > +		stats->tx_fifo_errors +=3D comp->sls_o_compressed;
> > +		stats->collisions     +=3D comp->sls_o_misses;
> >  	}
> > -#endif /* CONFIG_INET */
> > -	return (&stats);
> > +#endif
> > +	return stats;
> >  }
> > =20
>=20
> Hmm, this is wrong.
>=20
> Each time sl_get_stats() is called, you are adding stuff to dev->stat=
s

Hmmm, yeah. Sorry for the mess. That's completely wrong.

> Quite frankly I dont think its a kernel-janitors@vger.kernel.org patc=
h,
> its pretty normal netdev stuff.
>=20
> Please take a look at prior patch posted yesterday.
>=20
> http://marc.info/?l=3Dlinux-netdev&m=3D128213719605250&w=3D2
>=20
> Because either you should build your patch on top of it, or ask David=
 to
> revert mine before ;)

Oops, I didn't notice that one. I'll rebuild my patch on top of it.

> I advise using a ndo_get_stats64() so that you can perform the adds o=
n a
> private destination buffer.

I'll do that.

Thanks a lot
Tobias

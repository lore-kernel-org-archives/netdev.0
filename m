From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv3 2/2] sfc: Implement 64-bit net device statistics on
 all architectures
Date: Mon, 05 Jul 2010 20:31:22 +0200
Message-ID: <1278354682.2877.639.camel@edumazet-laptop>
References: <1276017594.2185.11.camel@achroite.uk.solarflarecom.com>
	 <1276017672.2185.12.camel@achroite.uk.solarflarecom.com>
	 <1278353780.2877.620.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:35573 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061Ab0GESb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 14:31:29 -0400
Received: by wwb13 with SMTP id 13so593661wwb.1
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 11:31:27 -0700 (PDT)
In-Reply-To: <1278353780.2877.620.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 juillet 2010 =C3=A0 20:16 +0200, Eric Dumazet a =C3=A9crit =
:
> Le mardi 08 juin 2010 =C3=A0 18:21 +0100, Ben Hutchings a =C3=A9crit =
:
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> > This is unchanged from v1.
> >=20
> > Ben.
> >=20
> >  drivers/net/sfc/efx.c |    6 +++---
> >  1 files changed, 3 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> > index 26b0cc2..8ad476a 100644
> > --- a/drivers/net/sfc/efx.c
> > +++ b/drivers/net/sfc/efx.c
> > @@ -1492,11 +1492,11 @@ static int efx_net_stop(struct net_device *=
net_dev)
> >  }
> > =20
> >  /* Context: process, dev_base_lock or RTNL held, non-blocking. */
> > -static struct net_device_stats *efx_net_stats(struct net_device *n=
et_dev)
> > +static struct rtnl_link_stats64 *efx_net_stats(struct net_device *=
net_dev)
> >  {
> >  	struct efx_nic *efx =3D netdev_priv(net_dev);
> >  	struct efx_mac_stats *mac_stats =3D &efx->mac_stats;
> > -	struct net_device_stats *stats =3D &net_dev->stats;
> > +	struct rtnl_link_stats64 *stats =3D &net_dev->stats64;
> > =20
> >  	spin_lock_bh(&efx->stats_lock);
> >  	efx->type->update_stats(efx);
> > @@ -1630,7 +1630,7 @@ static void efx_set_multicast_list(struct net=
_device *net_dev)
> >  static const struct net_device_ops efx_netdev_ops =3D {
> >  	.ndo_open		=3D efx_net_open,
> >  	.ndo_stop		=3D efx_net_stop,
> > -	.ndo_get_stats		=3D efx_net_stats,
> > +	.ndo_get_stats64	=3D efx_net_stats,
> >  	.ndo_tx_timeout		=3D efx_watchdog,
> >  	.ndo_start_xmit		=3D efx_hard_start_xmit,
> >  	.ndo_validate_addr	=3D eth_validate_addr,
> > --=20
> > 1.6.2.5
> >=20
>=20
> Ben, David
>=20
> I believe following patch is needed after our recent commits.
> Not sure a seqlock is really needed, maybe a spinlock would be enough=
=2E
>=20

One other way would be to add a rtnl_link_stats64 param to
ndo_get_stats64() method, and ask drivers to copy their stats in this
zone, instead of returning &dev->stats64 or something...

And also change dev_get_stats() with this new parameter.

Each caller would use a private copy, with no risk of concurrent
updates.




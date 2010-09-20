From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 7/8] sfc: Set net_device::num_rx_queues
 once we know the correct value
Date: Mon, 20 Sep 2010 20:05:46 +0100
Message-ID: <1285009546.2282.126.camel@achroite.uk.solarflarecom.com>
References: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
	 <1285008239.2282.110.camel@achroite.uk.solarflarecom.com>
	 <1285008867.2323.60.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9229 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757155Ab0ITTFt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 15:05:49 -0400
In-Reply-To: <1285008867.2323.60.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-09-20 at 20:54 +0200, Eric Dumazet wrote:
> Le lundi 20 septembre 2010 =C3=A0 19:43 +0100, Ben Hutchings a =C3=A9=
crit :
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> >  drivers/net/sfc/efx.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> > index 4a1c93f..48e2bf4 100644
> > --- a/drivers/net/sfc/efx.c
> > +++ b/drivers/net/sfc/efx.c
> > @@ -1315,6 +1315,7 @@ static int efx_probe_nic(struct efx_nic *efx)
> > =20
> >  	efx_set_channels(efx);
> >  	efx->net_dev->real_num_tx_queues =3D efx->n_tx_channels;
> > +	efx->net_dev->num_rx_queues =3D efx->n_rx_channels;
> > =20
> >  	/* Initialise the interrupt moderation settings */
> >  	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec, tr=
ue);
> > --=20
> > 1.7.2.1
> >=20
> >=20
> >=20
>=20
> Interesting, but why ?
>=20
> No other driver does this AFAIK...

If RPS is enabled there's a separate kobject for each RX queue.  Those
other drivers probably should be setting it.

Oh, but this only exists if CONFIG_RPS is enabled.  I think we need an
inline function for setting this.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


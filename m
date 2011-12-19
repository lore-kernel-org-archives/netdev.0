From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net] gianfar: Reject out-of-range RX NFC locations
Date: Mon, 19 Dec 2011 15:51:38 +0000
Message-ID: <1324309898.2797.15.camel@bwh-desktop>
References: <1324083927.2798.34.camel@bwh-desktop>
	 <1324111180.1813.8.camel@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54721 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750713Ab1LSPvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 10:51:41 -0500
In-Reply-To: <1324111180.1813.8.camel@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-12-17 at 09:39 +0100, Sebastian P=C3=B6hn wrote:
> On Sat, 2011-12-17 at 01:05 +0000, Ben Hutchings wrote:
> > Currently the driver only uses location values to maintain an order=
ed
> > list of filters.  There is nothing to stop the list becoming longer
> > than the filer hardware can support - the driver will report an err=
or,
> > but will not roll back the change!
> Sure that it does not do the rollback?
> In case of to much filters it should work this way:
> # Convert all in temp table
> # Compress temp table
> # Write out temp table =3D> not enough space =3D> discard temp table =
&
> remove filter from list=20

You're right, I must have misread the code previously.  Therefore, I
withdraw this patch for the time being.

> > Make it reject location values >=3D MAX_FILER_IDX, consistent with =
the
> > range that gfar_get_cls_all() reports.

I do however think that this should be consistent, and I would like to
reserve some 'special' location values.  But, for compatibility, it may
be necessary to use some other method to distinguish them (e.g. another
flow_type flag.)

Ben.

> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Reviewed-by: Sebastian P=C3=B6hn <sebastian.poehn@googlemail.com>
> > ---
> > [Re-sent to what I hope is a current address for Sebastian.]
> >=20
> > This has not been tested in any way, as I don't have a suitable com=
piler
> > installed.  Sebastian, please could you review this?
> Unfortunately I haven't too ...
> >=20
> > Ben.
> >=20
> >  drivers/net/ethernet/freescale/gianfar_ethtool.c |    5 +++--
> >  1 files changed, 3 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/dri=
vers/net/ethernet/freescale/gianfar_ethtool.c
> > index 5890f4b..5a3b2e5 100644
> > --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
> > +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> > @@ -1692,8 +1692,9 @@ static int gfar_set_nfc(struct net_device *de=
v, struct ethtool_rxnfc *cmd)
> >  		ret =3D gfar_set_hash_opts(priv, cmd);
> >  		break;
> >  	case ETHTOOL_SRXCLSRLINS:
> > -		if (cmd->fs.ring_cookie !=3D RX_CLS_FLOW_DISC &&
> > -			cmd->fs.ring_cookie >=3D priv->num_rx_queues) {
> > +		if ((cmd->fs.ring_cookie !=3D RX_CLS_FLOW_DISC &&
> > +		     cmd->fs.ring_cookie >=3D priv->num_rx_queues) ||
> > +		    cmd->fs.location >=3D MAX_FILER_IDX) {
> >  			ret =3D -EINVAL;
> >  			break;
> >  		}
> > --=20
> > 1.7.4.4
> >=20
> >=20
>=20
>=20

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

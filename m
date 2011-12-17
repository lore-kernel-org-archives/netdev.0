From: Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@googlemail.com>
Subject: Re: [PATCH net] gianfar: Reject out-of-range RX NFC locations
Date: Sat, 17 Dec 2011 09:39:38 +0100
Message-ID: <1324111180.1813.8.camel@vostro>
References: <1324083927.2798.34.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60162 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab1LQIiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2011 03:38:55 -0500
Received: by eaaj10 with SMTP id j10so3507926eaa.19
        for <netdev@vger.kernel.org>; Sat, 17 Dec 2011 00:38:53 -0800 (PST)
In-Reply-To: <1324083927.2798.34.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-12-17 at 01:05 +0000, Ben Hutchings wrote:
> Currently the driver only uses location values to maintain an ordered
> list of filters.  There is nothing to stop the list becoming longer
> than the filer hardware can support - the driver will report an error=
,
> but will not roll back the change!
Sure that it does not do the rollback?
In case of to much filters it should work this way:
# Convert all in temp table
# Compress temp table
# Write out temp table =3D> not enough space =3D> discard temp table &
remove filter from list=20
>=20
> Make it reject location values >=3D MAX_FILER_IDX, consistent with th=
e
> range that gfar_get_cls_all() reports.
>=20
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Reviewed-by: Sebastian P=C3=B6hn <sebastian.poehn@googlemail.com>
> ---
> [Re-sent to what I hope is a current address for Sebastian.]
>=20
> This has not been tested in any way, as I don't have a suitable compi=
ler
> installed.  Sebastian, please could you review this?
Unfortunately I haven't too ...
>=20
> Ben.
>=20
>  drivers/net/ethernet/freescale/gianfar_ethtool.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drive=
rs/net/ethernet/freescale/gianfar_ethtool.c
> index 5890f4b..5a3b2e5 100644
> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> @@ -1692,8 +1692,9 @@ static int gfar_set_nfc(struct net_device *dev,=
 struct ethtool_rxnfc *cmd)
>  		ret =3D gfar_set_hash_opts(priv, cmd);
>  		break;
>  	case ETHTOOL_SRXCLSRLINS:
> -		if (cmd->fs.ring_cookie !=3D RX_CLS_FLOW_DISC &&
> -			cmd->fs.ring_cookie >=3D priv->num_rx_queues) {
> +		if ((cmd->fs.ring_cookie !=3D RX_CLS_FLOW_DISC &&
> +		     cmd->fs.ring_cookie >=3D priv->num_rx_queues) ||
> +		    cmd->fs.location >=3D MAX_FILER_IDX) {
>  			ret =3D -EINVAL;
>  			break;
>  		}
> --=20
> 1.7.4.4
>=20
>=20

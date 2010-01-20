From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH 02/11] fs_enet: Add FEC TX Alignment workaround for
	MPC5121
Date: Wed, 20 Jan 2010 11:22:27 +0100
Message-ID: <20100120102227.GA5041@pengutronix.de>
References: <1263932653-3634-1-git-send-email-agust@denx.de> <1263932653-3634-3-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bg08WKrSYDhXBjb5"
Cc: linuxppc-dev@ozlabs.org, wd@denx.de,
	John Rigby <jrigby@freescale.com>, netdev@vger.kernel.org,
	dzu@denx.de, Piotr Ziecik <kosmo@semihalf.com>
To: Anatolij Gustschin <agust@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56709 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711Ab0ATKWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 05:22:36 -0500
Content-Disposition: inline
In-Reply-To: <1263932653-3634-3-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_=
enet-main.c
> index 909b78d..a391219 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -587,6 +587,33 @@ void fs_cleanup_bds(struct net_device *dev)
> =20
>  /***********************************************************************=
***********/
> =20
> +static struct sk_buff *tx_skb_align_workaround(struct net_device *dev,
> +					       struct sk_buff *skb)
> +{
> +	struct sk_buff *new_skb;
> +
> +	/* Alloc new skb */
> +	new_skb =3D dev_alloc_skb(ENET_RX_FRSIZE + 32);
> +	if (!new_skb) {
> +		printk(KERN_WARNING DRV_MODULE_NAME
> +				": %s Memory squeeze, dropping tx packet.\n",
> +								dev->name);

I understand this type of printk fits to the rest of the code, I just wonde=
r if
new (and patched) printouts shouldn't be converted to dev_*? Might be one l=
ine
then, and more consistent to what other drivers produce.

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--bg08WKrSYDhXBjb5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAktW2WMACgkQD27XaX1/VRs9MACgh+1XL6Cey54scoNcVzkIdMIQ
V0QAn2CMx/PNpLnJAddyYXyhtS8akRlb
=rO4C
-----END PGP SIGNATURE-----

--bg08WKrSYDhXBjb5--

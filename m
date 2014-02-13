From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [net-next 2/5] ixgbe: implement SIOCGHWTSTAMP ioctl
Date: Thu, 13 Feb 2014 20:03:09 +0000
Message-ID: <1392321789.15615.49.camel@deadeye.wl.decadent.org.uk>
References: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
	 <1392278450-27062-3-git-send-email-aaron.f.brown@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-uQ3Klt+E6QrJu7JCQMJD"
Cc: davem@davemloft.net, Jacob Keller <jacob.e.keller@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Aaron Brown <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55756 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751397AbaBMUDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 15:03:17 -0500
In-Reply-To: <1392278450-27062-3-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uQ3Klt+E6QrJu7JCQMJD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-02-13 at 00:00 -0800, Aaron Brown wrote:
[...]
> +int ixgbe_ptp_set_ts_config(struct ixgbe_adapter *adapter, struct ifreq =
*ifr)
>  {
>  	struct ixgbe_hw *hw =3D &adapter->hw;
> -	struct hwtstamp_config config;
> +	struct hwtstamp_config *config =3D &adapter->tstamp_config;
>  	u32 tsync_tx_ctl =3D IXGBE_TSYNCTXCTL_ENABLED;
>  	u32 tsync_rx_ctl =3D IXGBE_TSYNCRXCTL_ENABLED;
>  	u32 tsync_rx_mtrl =3D PTP_EV_PORT << 16;
>  	bool is_l2 =3D false;
>  	u32 regval;
> =20
> -	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
> +	if (copy_from_user(config, ifr->ifr_data, sizeof(*config)))
>  		return -EFAULT;
[...]

This is wrong.  You overwrite the current config before validating it.

Ben.

--=20
Ben Hutchings
The world is coming to an end.	Please log off.

--=-uQ3Klt+E6QrJu7JCQMJD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUv0k/ee/yOyVhhEJAQoNpw//eT/uE17n0xCTD71UTP6AiPkAmctQzVt9
LdGI6SRfmZktxsmlBMvM/16CIQY1WAZys5o9WsIQlcBErmAmOYCWxFZJVRaEDDsm
PtVvfS70dalh5cdlq8HhymxzIaKVYi9cPfD6a2HYjCPhpy/lZCsLrmxtw0fw9KFv
fp9Ta94+GdVMss02XDfn046KlJxZXnhyjxhvhPXafXp2ofQKvBGUd4G4UD6y03XA
dr7whDeYd4ybDMTjPYl7UhQv8A70vdDKnJqSZQc5vs6gDjehBpPT0/i+Xt2zmPbI
K/4UamAsDOA7U14CF/eFuXYnuwiQsgQK6W/OtsejH6mOBW/4A3eE88yBtY75Z9wG
h8OMFE5NpqdJrDABVNOgWItmzQe307VWROkaCk80L60lm+BsmCDunlVcmXPPMzCh
EklphiWQRJ6vyVGT0MTF8Y8uN907NKZxnniFzHltjwq2xBsZr7YPK8gYwY7fGyKB
DTYNr+AOi9wweW1SusmL488oEzS1f94ImlAwRi5iH6PfSKS89v2x7mp1TWOA26V1
xvP5Nn6SMM/mAg13JJcxZLRGt206e9bv7xBhJT70lGKdtZN06YactgSJB32ZC/b6
+Jw3PCADUMabDCQ4h02s3vLJvObX/887+3I8lQNpPm9wqw7RCh+yWGgJ8o92xuTZ
8E9b3RiOfvE=
=UNCa
-----END PGP SIGNATURE-----

--=-uQ3Klt+E6QrJu7JCQMJD--

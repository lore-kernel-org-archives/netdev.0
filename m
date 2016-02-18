From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V2 net-next 2/3] lan78xx: add ethtool set & get pause
 functions
Date: Thu, 18 Feb 2016 23:45:11 +0000
Message-ID: <1455839111.2794.51.camel@decadent.org.uk>
References: <9235D6609DB808459E95D78E17F2E43D404B37B5@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3bGcqpG/PN3qLgho3NPm"
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55638 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1425341AbcBRXp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 18:45:28 -0500
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D404B37B5@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3bGcqpG/PN3qLgho3NPm
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-02-18 at 22:40 +0000, Woojung.Huh@microchip.com wrote:
> Add ethtool operations of set_pauseram and get_pauseparm.
[...]
> +static void lan78xx_get_pause(struct net_device *net,
> +			=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0struct ethtool_pauseparam *pause)
> +{
> +	struct lan78xx_net *dev =3D netdev_priv(net);
> +	struct phy_device *phydev =3D net->phydev;
> +	struct ethtool_cmd ecmd =3D { .cmd =3D ETHTOOL_GSET };
> +
> +	phy_ethtool_gset(phydev, &ecmd);
> +
> +	pause->autoneg =3D dev->fc_autoneg;
> +
> +	if (dev->fc_autoneg) {
> +		if (dev->fc_autoneg_control & FLOW_CTRL_TX)
> +			pause->tx_pause =3D 1;
> +
> +		if (dev->fc_autoneg_control & FLOW_CTRL_RX)
> +			pause->rx_pause =3D 1;

This is incorrect; you should always return the manual settings
(fc_request_control flags) here. =C2=A0If autonegotiation is enabled then
your get_settings function will return the actual pause flags.

Ben.


> +	} else {
> +		if (dev->fc_request_control & FLOW_CTRL_TX)
> +			pause->tx_pause =3D 1;
> +
> +		if (dev->fc_request_control & FLOW_CTRL_RX)
> +			pause->rx_pause =3D 1;
> +	}
> +}
[...]

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.
--=-3bGcqpG/PN3qLgho3NPm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsZXh+e/yOyVhhEJAQodMA/+NMgiOzmxliuuZQX5B3weJiZtEnqDk5s4
CqnGchFFETF1CMOSY/PkJSj8XyVNk2N1BCHSt3bYZGNHccffdJVbPzye9aDUJ0Xu
kxNh84L8s314B3Y1xgRsJqXnSlgsjeq/Z4OnGO//Oa66ulAnm5ySVVUL2qqy15IL
Qd57X9QT39uDfxUXEKc+4ejnAjApBC8OOeJN/zZBbz9QWpa1uLQL5G9hc2ALfO80
Ev55AUQ3Lws9RoMekdMebOGG6vI9WjbD6DlQsMdlCU2IOW+kooqPK7DxKE3f83X6
UVUVtnpo7FkkVvySvGb59GVvOOBbi15VLu6F8rJC8HYOh4n0ZdZQL9xkANdDPTNQ
CaN34MDNBDqjfssPwjw8GtsnMF8y9/2d4Qqbo6lFzmE7RCrV8VDw7k+nfJja4QdB
wz5niZliQ8yk3+i7YWR6Fv2ZsUM2sC9+ZMnYsICfxkvOe3RngKVk+9BCJF0nMyjg
Kg34V5WsrpcISEv5TZFHYJuu/ZXFxx628GTCqQCgdCpC9sTKLtDhQ+whQUdsVm2G
zF27KC8SyhiZPK2VpDINrbLBYtxmGoiEEWBkzFqveYlSFdyDBZre92BPiy9hAVu1
+mqRjugcBRRKVue69tMK7OeNK9ropazG299tkmsVVp7f6+0lERBYyHkc5Nakw1pT
G81OwDKWKjo=
=cO8Q
-----END PGP SIGNATURE-----

--=-3bGcqpG/PN3qLgho3NPm--

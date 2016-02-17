From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 1/2] net: ethtool: Add support for PHY packet
 generators
Date: Wed, 17 Feb 2016 21:06:19 +0000
Message-ID: <1455743179.21571.6.camel@decadent.org.uk>
References: <1455741127-25453-1-git-send-email-andrew@lunn.ch>
	 <1455741127-25453-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ONQHj64BhKN5EVubfrdT"
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50609 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161829AbcBQVGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 16:06:39 -0500
In-Reply-To: <1455741127-25453-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ONQHj64BhKN5EVubfrdT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-02-17 at 21:32 +0100, Andrew Lunn wrote:
> Some PHY devices contain a simple packet generator. Features vary, but
> often they can be used to generate packets of different sizes,
> different contents, with or without errors, and with different inter
> packet gaps. Add support to the core ethtool code to support this.
[...]
> --- a/include/uapi/linux/ethtool.h
> +++ b/include/uapi/linux/ethtool.h
> @@ -1167,6 +1167,31 @@ struct ethtool_ts_info {
> =C2=A0	__u32	rx_reserved[3];
> =C2=A0};
> =C2=A0
> +enum ethtool_phy_pkg_gen_flags {
> +	ETH_PKT_RANDOM	=3D (1 << 0),
> +	ETH_PKT_ERROR	=3D (1 << 1),

What kind of error? =C2=A0CRC error, FEC error, symbol error?

> +};
> +
> +/**
> + * struct ethtool_phy_pkt_get - command to request the phy to generate p=
ackets.
> + * @cmd: command number =3D %ETHTOOL_PHY_PKT_GEN
> + * @count: number of packets to generate
> + * @len: length of generated packets
> + * @ipg: inter packet gap in bytes.

What if the PHY doesn't allow varying the IPG? =C2=A0Should there be a way
to find out what its supported IPG is, or to request the default value?

Similarly, should there be a way to find out the minimum/maximum length it =
supports?

> + * @flags: a bitmask of flags from &enum ethtool_phy_pkg_gen_flags
> + *
> + * PHY drivers may not support all of these parameters. If the
> + * requested parameter value cannot be supported an error should be
> + * returned.

Should, or must?

How does userland tell when the PHY has finished? =C2=A0Should it be
possible to cancel this (similar to ETHTOOL_PHYS_ID)?

What should happen if the stack tries to send a packet while the PHY is
in this mode? =C2=A0Is it discarded? =C2=A0Should the driver indicate carri=
er-off=20
so that this is obvious?

[...]
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1541,6 +1541,25 @@ static int ethtool_get_phy_stats(struct net_device=
 *dev, void __user *useraddr)
> =C2=A0	return ret;
> =C2=A0}
> =C2=A0
> +static int ethtool_phy_pkt_gen(struct net_device *dev, void __user *user=
addr)
> +{
> +	struct phy_device *phydev =3D dev->phydev;
> +	struct ethtool_phy_pkt_gen pkt_gen;
> +	int err;
> +
> +	if (!phydev || !phydev->drv->pkt_gen)
> +		return -EOPNOTSUPP;
[...]

Why should this be tied to phylib? =C2=A0Nothing else in the ethtool
interface is.

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.
--=-ONQHj64BhKN5EVubfrdT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVsTgy+e/yOyVhhEJAQrTvhAAoOl+KdzZ7Mp3O/5XOoMYH1LcGdj1IwHe
BYuJ8of0ZP8fblJ5gvx8nF5w2LiGhhd254EY5LPxORDNOApSSzcfSbHA6TL56ENC
hmsUqRgGLX7W6BDMRxFrwIFc/3lXb0RTT/Qss0NDz+aiu6xliqa0ADO9fzzDpERz
fx5XIdMFwtvsl9qV6HxYuqpXmoMH2NobVSOYlzv5bLJVz1P885YlDKhoIG4A9f81
BmUq6gRxxynbFb2DwE7gHkgcn82ESCSRUOT0q15wx0Yg4R3n72dmVUlslkc9Cl5l
MqnS9D+eGkXxib+s2taly3iWIayKSML/qYEvNCMUIz/rqlsu9Ls1PHn1ZvdtsJJV
t3jEnHIcUYobD3X0yuAxR7NKdpQomObIvDbddVmu7CuOrnx/kNCgBdONWN/jFs9/
58hE2h5SIgQwMrJiwj9bKuW2lN6ssbLWj4ENmy9OAWFqqB43zYuOPDbActpR9Kpc
R38M58OejUOCT6fjAUbEv7qjQBylTZTBIPxuClOzJfTrOF4pBdDb4ZN/cT1dOF5+
hJXb0CyXyOoZcAao76S6VXhGUgU6P2IFJlXg1D24b3ZpqKMSMGNWs1EvwDA8Jcch
l+Onaf3Bn9tNY9ZZNvFZ7Qll/a4/QaVGG4l3TtKpbf/RX4dXxBm2XORq9INWGf5F
0c4RucFN7l8=
=3Zw/
-----END PGP SIGNATURE-----

--=-ONQHj64BhKN5EVubfrdT--

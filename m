From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 2/5] gianfar: Fix on-the-fly vlan and mtu
 updates
Date: Sat, 22 Feb 2014 00:32:28 +0000
Message-ID: <1393029148.15717.66.camel@deadeye.wl.decadent.org.uk>
References: <1392816138-31645-1-git-send-email-claudiu.manoil@freescale.com>
	 <1392816138-31645-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3Cs4/Rqaod2QdcHQiSk8"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55435 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752896AbaBVAcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 19:32:47 -0500
In-Reply-To: <1392816138-31645-3-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3Cs4/Rqaod2QdcHQiSk8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-02-19 at 15:22 +0200, Claudiu Manoil wrote:
[...]
> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> @@ -582,18 +582,18 @@ int gfar_set_features(struct net_device *dev, netde=
v_features_t features)
>  	netdev_features_t changed =3D dev->features ^ features;
>  	int err =3D 0;
> =20
> -	if (changed & (NETIF_F_HW_VLAN_CTAG_TX|NETIF_F_HW_VLAN_CTAG_RX))
> -		gfar_vlan_mode(dev, features);
> +	if (changed & (NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX))
> +		goto reset;
> =20
>  	if (!(changed & NETIF_F_RXCSUM))
>  		return 0;
> =20
> +reset:
[...]

This is a really weird way of saying:

	if (!(changed &=20
	      (NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_RXCSUM)=
))
		return 0;

Ben.

--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-3Cs4/Rqaod2QdcHQiSk8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwfwHOe/yOyVhhEJAQqL8A//dVbQHTKuNPJBPHtMZb1FFUOi0yix7gT8
5rFyILtpwfHCVLgr+lm3K2XNkjpIqhryJQgNbIxDuGXyaAgFWquHQERFR+qxwli2
6dV3PsMi0J1FyQXSsLufH5zpchne7XTsU9I6oJwkYLRTX6Zb0qLTMJedA/CrbgT2
ciXf3yLZ46U9adpIdgcKS0OT9+5IUw+yobnqzmK6vk0/EusRaLYAx9P7DrSZe+ty
JEDDh7IfzyfwpI+R4M9yOlMh9Zkrh/ZGGJqb8rdINw59FFvLjXgG60rL/yzCkEjZ
M9EaCtPFART6P4iLbLcCfRpzDWHggYIU7YwT6mvqxKvkk6IrTSe2CpUoOALcgdkx
+0RbwBg4Ecbyx5btMlkv5hFzI8ovEgKwkyPMtC9JGayjv2UDFO8DT2ytpH30NV3j
XILygW/jmM3NJnCID5EZSYgHzNX1XXyA5CtnRWyaO5KZolZgVqpbJtsQMH9AKj4g
XlEmf5jyoG0hRQqXVeS173pIQ4LO7pIjsJBwK7haI+uUKAaSECbQnr7qZLZpaCsq
7jP0SiFr8w1Fs8LhslgJ3w0Apa5m5suGMlbDzchNDuZcDHazl4NpmdKnAw4Kdu7+
V02dT2rWL0xeZbkFRmHxyMqzjup33v+HQtvtEhOwRCukEmAc/2frcGqK5jmAjQ3n
sXBdnIeeCi0=
=e/HV
-----END PGP SIGNATURE-----

--=-3Cs4/Rqaod2QdcHQiSk8--

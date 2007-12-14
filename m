From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] mac80211: clean up frame receive handling
Date: Fri, 14 Dec 2007 13:14:03 +0100
Message-ID: <1197634443.16079.36.camel@johannes.berg>
References: <1197483844.6558.158.camel@johannes.berg>
	 <20071213204933.GD3083@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-vyMkho/Ki09YepF1Y++N"
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michael Wu <flamingice@sourmilk.net>,
	Tomas Winkler <tomasw@gmail.com>, Jouni Malinen <j@w1.fi>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35000 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764533AbXLNMRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 07:17:48 -0500
In-Reply-To: <20071213204933.GD3083@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vyMkho/Ki09YepF1Y++N
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > +static bool ieee80211_frame_allowed(struct ieee80211_txrx_data *rx)
> > +{
> > +	static const u8 pae_group_addr[ETH_ALEN]
> > +		=3D { 0x01, 0x80, 0xC2, 0x00, 0x00, 0x03 };
> > +	struct ethhdr *ehdr =3D (struct ethhdr *)rx->skb->data;
> > +
> > +	if (rx->skb->protocol =3D=3D htons(ETH_P_PAE) &&
> > +	    (compare_ether_addr(ehdr->h_dest, pae_group_addr) =3D=3D 0 ||
> > +	     compare_ether_addr(ehdr->h_dest, rx->dev->dev_addr) =3D=3D 0))
> > +		return true;
>=20
> Should you reverse these two compare_ether_addr calls?
> rx->dev->dev_addr seems more likely for any given packet.  It probably
> makes little difference but it seems like checking for that first
> would still be better.

I think in theory all eapol frames are sent to the PAE group address,
but I have no idea which of the checks would be more efficient. It seems
that the first could be optimised a lot because it's constant too...

johannes

--=-vyMkho/Ki09YepF1Y++N
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR2JziaVg1VMiehFYAQI1hw/5AUc49QxnVte0QaTBmFksMjn4MqnJApuu
q1sHo5DVutvmrxVvR5kV0AeleVb//1uyMT1mXOOgN+uZqAlzlqi1qvBVA5j87KxA
B4oQcwISSQ9Pu+SPiBLtSBQ9IlwN+dG1Wuyn6hrjXOkpF6YlSuXN7bh53OFsxALw
CGZGMPZ66UCpabSb23qOWjW3ea016gPGFnt4EA8UijrsQ5sQRoV8wnAscVrkzVoP
LGJ1Aq4cHTxoTWrWf6e8AGnendflzQG0dT6KXjfgNcv3q0TySKh6XGAp7PzLx9Zt
q8FDLB6xk0+Ntul3xW8ZxxbjZozg8yH1QtBzOIzv5Y4lyIgkAPUTum6WLrOhTgUy
5ISCrJqFw6Z9vW//zV9c1Xy86bi+zppxOTG3s/2xz5dObB5B0mipc0LdgJM3k04m
dNy/0WNP5DYMN1sX2K+6qumgxHjMV3dR1GS76wXTn3sODwSFum3Nvf27vEfLqsSK
FaewNuSj1eOD1kEAvJ6AZxP5ZiXmUZcCS5KeLC+8F3mcEHFKsH26JMmTI76e68ef
5XDRX3egbv4sYkppfV0tWygo6K/a7V5Q3uEOtbaRKwiiDk8cxSZf3de2+0QYs+M7
+NRbFUEAPEY398PAbliGOmzd4Z67Dm6hoNFPkkl1GeTgBmfm+Ckv23/8W/2e8aKh
n+EFzgRBFfk=
=iFoJ
-----END PGP SIGNATURE-----

--=-vyMkho/Ki09YepF1Y++N--


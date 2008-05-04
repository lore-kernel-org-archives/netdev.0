From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] mac80211: assign needed_headroom/tailroom for netdevs
Date: Sun, 04 May 2008 23:31:18 +0200
Message-ID: <1209936678.7304.14.camel@johannes.berg>
References: <1209936253.7304.10.camel@johannes.berg>
	 (sfid-20080504_232356_925288_0C998746)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-iC2or/KMOk3LqaZ5oiLH"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1209936253.7304.10.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org> (sfid-20080504_232356_925288_0C998746)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-iC2or/KMOk3LqaZ5oiLH
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-05-04 at 23:24 +0200, Johannes Berg wrote:
> This assigns the netdev's needed_headroom/tailroom members
> to take advantage of pre-allocated space for 802.11 headers.
>=20
> Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> ---
> Builds on my other patch to add those fields, of course!
>=20
>  net/mac80211/iface.c |    8 ++++++++
>  net/mac80211/tx.c    |   14 +++++++++-----
>  2 files changed, 17 insertions(+), 5 deletions(-)
>=20
> --- everything.orig/net/mac80211/iface.c	2008-05-04 15:40:53.000000000 +0=
200
> +++ everything/net/mac80211/iface.c	2008-05-04 16:08:45.000000000 +0200
> @@ -53,6 +53,14 @@ int ieee80211_if_add(struct net_device *
>  	if (!ndev)
>  		return -ENOMEM;
> =20
> +	ndev->needed_headroom =3D local->tx_headroom +
> +				4*6 /* four MAC addresses */
> +				+ 2 + 2 + 2 + 2 /* ctl, dur, seq, qos */
> +				+ 6 /* mesh */
> +				- ETH_HLEN /* ethernet hard_header_len */
> +				+ IEEE80211_ENCRYPT_HEADROOM;

Although this seems to have worked for me, that was most likely
coincidence because I had two bytes extra headroom and no fourth MAC
address, I actually forgot 8 bytes here (rfc1042/bridge tunnel
encapsulation)

johannes

--=-iC2or/KMOk3LqaZ5oiLH
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB4rJaVg1VMiehFYAQISGA/+Ld0iBrt4IOvUdNvlDjhE7YRGIFcdUri9
hMmYP+kbHsWCSqz8ZA1QQC6opOwNtmpQCcpcruVq8m5LxWn/jGukgyYP5ccVh3ho
NpG+8juR05ZyEAhX3ojFJcEx6/FOWasznVulSmYfUprVPjEJZyJ7HkCNNMcbZN3t
ekUzIA9fiQNzSQJZKXLa51PzHp2z3gqj6P7dRJlweyp/Is4+CsFEYQF88qUp1SRY
RFcF22SSAObLhshchBwMDt8cOCJsTLNtUg1o5jqox+cyf8/oTuS+9+K8vcrHJdST
d3dRIgCnARkfPNl6XwCdZdvhg5UTkWu3Cg8Nm+SymoLA4NtSHW43ZEIIgrqtYRUn
P0PZYU8m9lkW447zB3hjdFGLYZv2t4RQ06c54RQANfs2epnuBwXsoXJ7EtEozkGQ
SVG4/PS5P+kl5LC5/LinRdb5X40Y/5HPB7zN9Tx1EmqTrkNtYglLJ8OPh4VoSPgc
T/qAy3PHw0TBIj9RZ6oGFMbLjtQKZojJWtJdzJtcTTO+NMpo+UqlmALnViQWGnSh
5T4Ji6KnA1jhI3mhlVPqhTmJywJMisAvQvpDuYYq0Qz9TcH3h0TxYN5txM1T4+e2
cHD4KOCKwbYVcdpu9TJo2Srly1e8lLiZMMwcTXl35EjBCmGSaw1UGcwNndmU/DoZ
ZUwHy3cPLEk=
=8thD
-----END PGP SIGNATURE-----

--=-iC2or/KMOk3LqaZ5oiLH--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

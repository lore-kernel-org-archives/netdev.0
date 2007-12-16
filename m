From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC] mac80211: clean up frame receive handling
Date: Sun, 16 Dec 2007 14:49:34 +0100
Message-ID: <1197812974.16079.64.camel@johannes.berg>
References: <1197483844.6558.158.camel@johannes.berg>
	 <c85cb4470712160128t7ef525f3md56d05f5990eb81@mail.gmail.com>
	 (sfid-20071216_092840_096498_4E5966AB)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-qZuDqfzsEqgmRAHBBlIe"
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jouni Malinen <j@w1.fi>
To: Ron Rindjunsky <rindjon-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <c85cb4470712160128t7ef525f3md56d05f5990eb81-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20071216_092840_096498_4E5966AB)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-qZuDqfzsEqgmRAHBBlIe
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > +       if (local->bridge_packets && (sdata->type =3D=3D IEEE80211_IF_T=
YPE_AP ||
> > +                                     sdata->type =3D=3D IEEE80211_IF_T=
YPE_VLAN) &&
>=20
> i may miss something, but wouldn't you prefer to use eth_type_trans
> here and just add compare_ether_addr check after it?

Yes, I think I would, but I also think it's wrong to call
eth_type_trans. We always remove the rfc2042 header and replace it with
a regular ethernet header; but in the case there was no rfc2042 header
we just stick in the length. But the length of a wireless packet can be
bigger than the 1536 below which eth_type_trans assumes it's a length,
so when we stick in a length>1536 it'll assume it's not a length but
rather an ethertype, which will be wrong.

The thing is, I couldn't so far even find the case where we receive a
frame *without* rfc2042 header.

johannes

--=-qZuDqfzsEqgmRAHBBlIe
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR2Us7aVg1VMiehFYAQLzAg//REdQDYuRxgLTUch3P8cIt742uJ5fzwv8
YnCDsgs65QxCau1ODW4TNV9oBA5CUY9SFP8vN4cbXHlm6yRPnym2N0k9vhdNrXV9
9tUOe5MTjB5fisctGf1GolJE1ujtrk80QvPt/mxBvkMAK/BmYEbB+31OIJ53qoiQ
//7VC7cfy/PQ1x9cC+4/kx8dpV3DEGRabg7teL/ByBE705mtuZ6jf2ePSkI0fZRX
V/Rlza03E6xgAtDQLbwj1pS3L++510xioVyQcmAFiWWUuPxpYIGPN4n/23e4/dsp
uvnNRUWcg+5ojFet/aO7xKl/FyxgPKBmOpx+vDt+ojlGh/IhpCbTM/HW5Yl+5qzx
Qy3DtGCRkTLETr1m7zhupgP0ipFrm4g7D6mUGyPBW6UPBgXQYo6hOSNXwhtlrnLd
zRdBtGbZ+c+qLm1Y9fa5Emmtso+8fNeIGILgS0c8jfEFhC8zPJOEy5wP7wO45n3u
gn1w5tDK/UiK48hOI4Rz/4tUjGBnUyvteVv+e1r9Cje0FCExr7Pzz++QtpS/dm7L
HSesV/KWKoJQHlwz2rix/YobT06uUFL6Et1R5NEjrW9hhjaXZ/YnBNmP8bZpW2h4
OGFPBOauTifuEobzPmQkmqF5zYNKjUTdLD/gc64bRdstU5M9KTfxCEIJI/M4H6QR
2cgYHxPktE8=
=zwJZ
-----END PGP SIGNATURE-----

--=-qZuDqfzsEqgmRAHBBlIe--

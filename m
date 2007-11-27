From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [Bridge] Re: [RFC] bridging: don't forward EAPOL frames
Date: Tue, 27 Nov 2007 16:28:41 +0100
Message-ID: <1196177321.6058.30.camel@johannes.berg>
References: <1195737808.6323.102.camel@johannes.berg>
	 <20071126093626.08c22a9d@freepuppy.rosehill.pdx.hemminger.net>
	 <1196169854.6058.16.camel@johannes.berg>
	 <bdfc5d6e0711270724i3ce7cf41lb5f01dd5dcac98f9@mail.gmail.com>
	 (sfid-20071127_152407_326070_3E3E1011)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-l0fIdHcss+50CeiKNcQv"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	bridge <bridge@linux-foundation.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:47757 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756701AbXK0P3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 10:29:05 -0500
In-Reply-To: <bdfc5d6e0711270724i3ce7cf41lb5f01dd5dcac98f9@mail.gmail.com> (sfid-20071127_152407_326070_3E3E1011)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-l0fIdHcss+50CeiKNcQv
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > > Not needed because the bridge is already handling it:
> > >
> > > 1) If running STP (ie true bridge), then all link local multicast is =
only received by
> > > the bridge and never forwarded.
> >
> > Well, typical access point setups bridge the wireless AP interface with
> > wired, EAPOL frames can be unicast (and 802.11 specifies to do so) and
> > we want to avoid having them unicast to another host.
> >
> > Also, 802.1X in C.3.3 recommends not bridging the *ethertype* rather
> > than depending on the link-local multicast address because otherwise
> > eapol frames can be unicast into the network behind the (authorized)
> > port which is undesirable.

> I agree with Stephen, that based on the way it's likely people use
> linux bridges it seems like this is something that could be configured
> rather than simply dropping those frames without any chance to forward
> them.

Well Stephen is wrong in one thing that eapol need not be link local
multicast for 802.11, it's unicast there so the dropping of link local
packets doesn't help.

> There are probably quite a few people out there who will not
> expect this change, so it should be easy to change during runtime.

I'm not aware of any use for EAPOL frames traversing the network. I'm
also not aware of any proper 802.1X implementation for linux bridges but
I didn't do too much research yet. I don't see why people would rely on
EAPOL frames being bridged when the protocol is by definition local to a
link.

> Don't forget that a simple ebtables rule could also drop EAPOL if needed.

Indeed, but I'd prefer the bridge to do the right thing in absence of
configuration.

johannes

--=-l0fIdHcss+50CeiKNcQv
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR0w3p6Vg1VMiehFYAQJUthAAnPXiJnolsg5QgSze/nnej6nGKwuM6hED
smXBe1wEjP1sCHB2HgvXzYAwJdb9XnQh0IQjCu6cg4zfWFpMaiVcRaqj8WKyXyBF
/c6d4Zc4Jo3q7WcrWeWeWn/Hwr5RM7cP5q5/tRaNL0uxtJtG81tRmApBca+7Z41V
yEZVdkQuUQhmY8yZx6pSAx68YyF9Z7sWVaJCxIaXphvqsMARB6ng5efv3GWx0oLE
hAtMsK8lgEjl0HN2HQKIrJJh0oC6t4thxY2IMa811hPHNcX5zADbudzDETd48Suq
Xth86jwmbOmYZ/zW8oemKpmzHmR17UK6xZ0cfJB7ocNjcJnqZgeGvvlTmJO0tiwi
eeK/ftPjzMJ9SOaxpyRUs2Tgh3uI/lot8W+XjT/SLws6wKQ+F9Na0HB6erc477YD
SsJAnQoSESdRK24PrDd9/pV0H3EJl1+5ooETjGXltTNVdCV9fCinPLps74oQaI8J
8cVat9t1C96aMPAtUkM95j1anVD3regtMnW1TQVyIi/4nKeENU13lk3zbjZlOHOh
gEinBsMLu9Jvq6ZSVd73clp/eBl+2d7xzqEWpQLWgfPM+686oHcKpHy3lV2Yiqu2
tTcHDcyzysVWnmodIvXdtI2nhB1NXkyJAud2F2ZyBiVBxAweSFJ36LPci8OdrFxY
d+tdKX4Bn0Q=
=RuEA
-----END PGP SIGNATURE-----

--=-l0fIdHcss+50CeiKNcQv--


From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] bridging: don't forward EAPOL frames
Date: Tue, 27 Nov 2007 14:24:13 +0100
Message-ID: <1196169854.6058.16.camel@johannes.berg>
References: <1195737808.6323.102.camel@johannes.berg>
	 <20071126093626.08c22a9d@freepuppy.rosehill.pdx.hemminger.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-s4FunQb3jpUchbD9j7s5"
Cc: netdev <netdev@vger.kernel.org>,
	bridge <bridge@linux-foundation.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35494 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbXK0NYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 08:24:21 -0500
In-Reply-To: <20071126093626.08c22a9d@freepuppy.rosehill.pdx.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-s4FunQb3jpUchbD9j7s5
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > +	if (unlikely(skb->protocol =3D htons(ETH_P_PAE)))
> > +		goto drop;
> > +
> >  	switch (p->state) {
> >  	case BR_STATE_FORWARDING:
>=20
> Not needed because the bridge is already handling it:
>=20
> 1) If running STP (ie true bridge), then all link local multicast is only=
 received by
> the bridge and never forwarded.

Well, typical access point setups bridge the wireless AP interface with
wired, EAPOL frames can be unicast (and 802.11 specifies to do so) and
we want to avoid having them unicast to another host.

Also, 802.1X in C.3.3 recommends not bridging the *ethertype* rather
than depending on the link-local multicast address because otherwise
eapol frames can be unicast into the network behind the (authorized)
port which is undesirable.

johannes

--=-s4FunQb3jpUchbD9j7s5
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR0wafKVg1VMiehFYAQJJLw/+KrHUQAvf/h2hb1wlS4vu4DXdinHA5EhH
tjWjNBVz3bNx6jyN6P89+q+Mr9KHEzro27fbj1mCnXTG+g6vt581TnLg/v4s7Qeh
eTg2A5L4AVjOmc8c53ZKZynCGqIQuPFmKKyyUI2v0MBwR+4gCQWqt7s7Z7msETfD
XXhWNCaWpzcMdX1regrfWKekRm3/stFpAS4GpKGIWj/TkwQQWElXhtmXGa/SAChb
msi8qSi/kB5+e5c84ay5qLsdCODF4cSm5siAgu+CdvNZTUpQMauS/mud+NSN2H0B
4DLaOifYkSwlThE19vKWLWx/2X0NdMNLpB292EY+FasFuv7XaskHvQ8S0blv+Uj+
1jtRWkFA+S+XztMGvJ+NuyG/M2bbvJ5wfTExHp3CTFyMnYTqH5fECVLwHPpR41/Q
IIA6TnYk2Ox6ALADaQWwsOCwfdHliqtgZ1bqYNyX2OZLq8BgW3k3F8agOcktneQr
rlnKsI14ILzz5aCFA12FHp20ocSPRxCAm/YYyoIlLYYQ3ZFNEdlTkZnTRBQV2v+4
1lX6ljgzIkIGoKOGqK6KNUPDrMh9wLhViXQrE1ii1frCZlhS8VBE3E/kFjyl/7EC
JUiHlnDWyuyf/lL6oqz3gQxKGngdiFTuzLFYL2xybQWqOPMHah32MochSm9NQwCB
+rg0BJQQOeY=
=T8vE
-----END PGP SIGNATURE-----

--=-s4FunQb3jpUchbD9j7s5--


From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH net] netpoll: fix rx_hook() interface by passing the skb
Date: Tue, 22 Oct 2013 19:13:14 +0200
Message-ID: <20131022171314.GL1544@neomailbox.net>
References: <20131022.025038.1046903740187748879.davem@davemloft.net>
 <1382431715-3128-1-git-send-email-antonio@meshcoding.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B739B@saturn3.aculab.com>
 <20131022101127.GJ1544@neomailbox.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B739F@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="qyHYMwAXsHLOQihY"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:33420 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234Ab3JVRN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 13:13:57 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B739F@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qyHYMwAXsHLOQihY
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 22, 2013 at 01:46:22PM +0100, David Laight wrote:
> > Subject: Re: [PATCH net] netpoll: fix rx_hook() interface by passing th=
e skb
> >=20
> > On Tue, Oct 22, 2013 at 10:09:00AM +0100, David Laight wrote:
> > > > Subject: [PATCH net] netpoll: fix rx_hook() interface by passing th=
e skb
> > > >
> > > > Right now skb->data is passed to rx_hook() even if the skb
> > > > has not been linearised and without giving rx_hook() a way
> > > > to linearise it.
> > > >
> > > > Change the rx_hook() interface and make it accept the skb
> > > > as argument. In this way users implementing rx_hook() can
> > > > perform all the needed operations to properly (and safely)
> > > > access the skb data.
> > > ...
> > > > -	void (*rx_hook)(struct netpoll *, int, char *, int);
> > > > +	void (*rx_hook)(struct netpoll *np, struct sk_buff *skb, int offs=
et);
> > >
> > > You can't do that change without changing the way that hooks are regi=
stered
> > > so that any existing modules will fail to register their hooks.
> >=20
> > There is no hook registration in the kernel tree. All the users are out=
side.
>=20
> Looking at __netpoll_rx() I notice that there isn't an skb_pull for the
> udp header.
>=20
> Actually, I think the alignment rules effectively imply that iph->ihl
> (the second byte) will always be in the first skb fragment so the
> code could sensible do a single skb_pull() that includes the udp header.
>=20
> I can't remember which value you passed as 'offset' (and my mailer makes
> it hard to find), but to ease the code changes the offset of the udp data
> would make sense.
> In that case you still need to pass the source port.

I decided not to pass the source port because if the user is really interes=
ted
in it, it is still possible to get the udp_hdr from the skb and read its va=
lue.

> If you do rx_hook(np, source_port, skb, offset) then if anyone manages to
> load an old module (or code that casts the assignement to rx_poll)
> at least it won't go 'bang'.
> Renaming the structure member will guarantee to generate compile errors.
>=20

so you suggest to rename rx_hook to something else to warn people about the
change?

If we go for the "no udp port" approach they will get an error any way beca=
use
of the mismatching arguments.

Regards,

--=20
Antonio Quartulli

--qyHYMwAXsHLOQihY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSZrIqAAoJEADl0hg6qKeO5XUP/1PDo22MKgXLgnz7uO76hyPq
IO3ygL1H7rUAsvxA+u2iZOOuPGQfcXmdhnmXuH6EbZjQNZI8DQyjU+VWCTAlYKSN
EhMg+m0m3kOta+uzhRjGZRjen/s7ja9mD/O9m9o9JP3DvH+FEkA4pb1oTVVwFbcq
eHh0OVCPgjC4fsqNOlCRL9r6S4BZIlCRKknVQrNBMgwkm7YVS067dVeVBYSUY35C
EPJjMxg9oeJdmI8fe6/HmUkcj23gYrz/Ss93tQHALdBEivfnr/WIZVxhDwFjnPrv
fIYsIjMeAKY9Ru7QugmrKLWIY0DF4Li83w5fQLhkod1KfbdAaTNoYJ2TzrMPid/V
WgPkDOqKtg0BD6EtbmfmTg7S4QEn0C8dTKG2OBdHXtHD8hBTmW1ow/zMzlr6Rndr
NGkHj+laAHjCTGRYYOv7J6Lt+QUj7KpfvJOe6CP7iVh1GHNCaqTR7/xiBGhRsK5G
GgKztWoa1i5B3QNs81WKul10nMKoLx/v2kr1yR/JhiHwGO1pqxInOqnqmlgqn3B2
yCr/bJEhazcpL7aCTVvoIXAD1XnORwCGJYg/bk46/ml0TurdVIM8+QxeKbducV1W
YZS0xQzmMiWXTDPrdhqIGE5EikGOZqkgMchb9ufk9nXPdbBohbnga0uSb0MqF+Fg
ay98aOhB6E8KEOtdpkKN
=c2XW
-----END PGP SIGNATURE-----

--qyHYMwAXsHLOQihY--

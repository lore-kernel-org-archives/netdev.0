From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] netlink: add socket destruction notification
Date: Mon, 09 Nov 2009 14:03:07 +0100
Message-ID: <1257771787.29454.173.camel@johannes.local>
References: <1254473048.3959.76.camel@johannes.local>
	 <4AF43EF9.3020707@trash.net> <1257521204.29454.31.camel@johannes.local>
	 <4AF442C2.9040704@trash.net> <1257762132.29454.161.camel@johannes.local>
	 <4AF8122F.9060807@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-qV0G4NF4tvWkEEFiLXxE"
Cc: netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:37688 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbZKINDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 08:03:06 -0500
In-Reply-To: <4AF8122F.9060807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qV0G4NF4tvWkEEFiLXxE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-11-09 at 13:59 +0100, Patrick McHardy wrote:

> > Thanks for the explanation. I think we'd need the second condition
> > removed, I don't see a reason to force a socket to not also have
> > multicast RX if it's used for any of the purposes we're looking at this
> > for. Guess we need to audit the callees to determine whether that's ok.
>=20
> I've already done that. Its currently only used by netfilter
> for which this change also makes sense.

Cool, I arrived at that conclusion too, it seemed that it would
currently be somewhat strangely broken if you could add multicast groups
to those sockets used there. Not sure if you can though.

> > Can you quickly explain the difference between release and destruct?
>=20
> release is called when the socket is closed, destruct is called
> once all references are gone. I think with the synchonous processing
> done nowadays they shouldn't make any difference, but release
> should be fine in either case.

Ok, cool, thanks. Do you want me to send the change removing the
multicast check, or would you want to do that since you audited all the
netlink callers?

Also, it's called URELEASE for unicast -- should we rename it to just
RELEASE?

johannes

--=-qV0G4NF4tvWkEEFiLXxE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK+BMHAAoJEODzc/N7+QmaCTkQAMc7KxbX7HlXWNrjjWaVEd53
9UuYW7V2K7UlkYA/Lsheuim0cDLGy9bshbDb6ZxCe2CGFIgy4ePFohc2kK1B9iXU
+sLUJlOMv8w8Hu+5svC2h2RxH2nT9wMFTdjkE7GO8yiLLWEe0VNpHqsq+XZzXkY8
cVHlvrGoXi4Yxc++c8DXJLc8PwSeKBX6cbEPiu3tAV79k7U2J6AcUAOFkTTzLdJA
mHsHFx2pHAezriIxHBUqtkZo4NDVooZ4ti09FC8iicPT8+o97FaaPrc05IqLNbb1
eecAVxCHFGyHutT9PMPDwErFf/DsdTxfXOGg5AhPiQAonqHprm1Z/S7XW+qUrBhU
G8MQXs2KKKyNXOpXeKQJGCxEOnEC9Ve/1b4GkhkTqi1ENTPlp5yKi082ZKm6eI2j
kqfAF+FyV5VgKJqw3hY+oZJHX7Nhme2X6mvIDeJRcCHFyRGxrJj8m2rAha4t1Yyo
qlKwZ4oxcUXewgUJNOwjsBrS7yvE9drjOgMa698pk6fYAB9xySd3lfkDI0QaH6bc
iCGZJPv+27Ey+739dAz17hc06onUnRCbl/stMb3fJALeaD9SMevNeG8YKJBdLnNX
BbhazxtozuyrwSQkrm9fjqDSVbrrzi5LTWTgo7wIweJl8U8oVWtDaNnO7NbGmMxI
q+dk7SECmsqhsGei5a8h
=1XcK
-----END PGP SIGNATURE-----

--=-qV0G4NF4tvWkEEFiLXxE--


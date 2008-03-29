From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Sat, 29 Mar 2008 01:54:09 +0100
Message-ID: <1206752049.22530.105.camel@johannes.berg>
References: <20080328000013.GA8193@codemonkey.org.uk>
	 <20080328.173414.22278840.davem@davemloft.net>
	 (sfid-20080329_003421_542132_91288803)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-4alJGhWQbKY9MXcQ12ou"
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:55642 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754108AbYC2AyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 20:54:20 -0400
In-Reply-To: <20080328.173414.22278840.davem@davemloft.net> (sfid-20080329_003421_542132_91288803)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4alJGhWQbKY9MXcQ12ou
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> >  stack backtrace:
> >  Pid: 2308, comm: NetworkManager Not tainted 2.6.25-0.161.rc7.fc9.i686 =
#1
> >   [print_circular_bug_tail+91/102] print_circular_bug_tail+0x5b/0x66
> >   [print_circular_bug_entry+57/67] ? print_circular_bug_entry+0x39/0x43
> >   [__lock_acquire+2488/3089] __lock_acquire+0x9b8/0xc11
> >   [_spin_unlock_irq+34/47] ? _spin_unlock_irq+0x22/0x2f
> >   [lock_acquire+106/144] lock_acquire+0x6a/0x90
> >   [flush_workqueue+0/133] ? flush_workqueue+0x0/0x85
> >   [flush_workqueue+68/133] flush_workqueue+0x44/0x85
> >   [flush_workqueue+0/133] ? flush_workqueue+0x0/0x85
> >   [flush_scheduled_work+13/15] flush_scheduled_work+0xd/0xf
> >   [<d096d80a>] tulip_down+0x20/0x1a3 [tulip]
> >   [trace_hardirqs_on+233/266] ? trace_hardirqs_on+0xe9/0x10a
> >   [dev_deactivate+177/222] ? dev_deactivate+0xb1/0xde
>=20
> Yes, see for example:
>=20
> http://www.mail-archive.com/netdev@vger.kernel.org/msg31718.html
>=20
> You can't flush a workqueue in the device close handler
> exactly because of this locking conflict.
>=20
> Nobody has come up with a suitable way to fix this yet.

Maybe we should check which schedule_work users actually lock the rtnl
within the work function and move them to a uses-rtnl-in-work workqueue
so that everybody else can have rtnl around flush.

Depending on how many users there are that might not be feasible, but I
have so far only seen linkwatch_event() lock the rtnl within the work
function and everybody else seems to want to use the rtnl around the
flushing.

johannes

--=-4alJGhWQbKY9MXcQ12ou
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR+2TMKVg1VMiehFYAQLd2w//e0EUg28DeezoCfqBFXYLVktbA5vzzCHo
Y+X/DF/UZ08iCIdesCES1YuiL529c9tlbZUutNB0+aY9lc0ffrw7UmDWwK26Uni0
3sF5GaSw+PpoO+CmQp7W9/j/gEcczBnzEPIvGgW3kg/oM7NPgFAgNX8bJSEnaM6y
DSw+76yRCvcYSo+kOku24jdQqySvhJURhmaL7uCHn2AGc984nU8+fYibQg/ktffQ
w0BtKQCkpmfceUKGXoT4OgoSfJFTjeZuRBC0A4MZC51fc7btmvEzQfGoY27yvV4D
+OrUUMFNkzYPIGzUG4HTH+D3Im8wxUwCoDkvY8qQRkYSYzqFm4nMj5fmUlpYiteA
1uDSaG2G5iHfket5tINf1INUuQNhi4o5IO7eZCE8CM5F+sXboRszYDRjgyk6+H32
dJThA2T5Kz4EyWp5xLH5yyrtMJYGQnBHIo2BEKC7Q8y+32A4JxPSoZrq4T7ZsyOy
WPK3eimb10bHUjo2WUzMDTu3YR9aVyIlnwsBWi4YWr2ws5wE8YerxxS302/vqULR
1HJ7F3k9cDCx61DBHcQuYTj7DQZqGR1qLfvB3dRPTIin8jMbUyddv9H7kOZxdZRO
C5xsLtqVz621Oi3NZTO2D/5ZtFYDjxbcENdY2CE/CY7cdUgQ18oY1XVLnww3oj+S
MAsOtPUl6rg=
=lvT0
-----END PGP SIGNATURE-----

--=-4alJGhWQbKY9MXcQ12ou--


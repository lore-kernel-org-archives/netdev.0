From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: zd1211rw (2.6.22 sparc64): unaligned access (do_rx)
Date: Tue, 20 Nov 2007 14:15:40 +0100
Message-ID: <1195564540.10920.13.camel@johannes.berg>
References: <4740DF47.4040206@hotmail.com>
	 <20071119.002755.77617097.davem@davemloft.net>
	 <20071120.043423.42170421.davem@davemloft.net>
	 (sfid-20071120_123450_985935_82C552CF)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-MFIgs6Tdf/zYM+hIvEJP"
Cc: shaddy_baddah@hotmail.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Jean Tourrilhes <jt@hpl.hp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:37336 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbXKTNtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 08:49:14 -0500
In-Reply-To: <20071120.043423.42170421.davem@davemloft.net> (sfid-20071120_123450_985935_82C552CF)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-MFIgs6Tdf/zYM+hIvEJP
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> I think I've figured out what's happening here.
>=20
> The kernel makes no effort whatsoever to translate iwe streams in
> compat environments.  And userspace then tries to "correct" this and
> does so miserably.  Likely this is what causes the bus error.

Quite possible. I wanted this fixed too but Jean refused to do it in the
kernel. And personally, I'm no longer touching wext with a 10 foot pole.
Too much backslash.

> The fix is that we need to add some handling code
> fs/compat_ioctl.c:do_wireless_ioctl() for the case where we are
> returning an iwe stream (SIOCGIWSCAN).
>=20
> It should not be very difficult to do this, since the compat format
> will be the same size or smaller, it should be easy to recode the
> thing in-place in the user buffer.
>=20
> So you make a pass over the user buffer fixing things up and then you
> adjust the iw_data length for the new size.
>=20
> Alternatively, you can allocate a kernel buffer for this, use a 'fs =3D
> get_fs(); set_fs(KERNEL_DS); ioctl(); set_fs(fs);' sequence, fixup the
> iwe stream, then copy the everything back out to userspace.

That may work, but wext also broadcasts iw_point inside netlink messages
for scan notifications etc. I don't see a good way to fix this part.

> Then we can delete all of this incredibly stupid code in the wireless
> tools that attempts to fix this up in userspace.

I wish. Really, I do.

johannes

--=-MFIgs6Tdf/zYM+hIvEJP
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR0Ld+6Vg1VMiehFYAQKLABAAqSL1qBBS8WcW62e14jE+aHxsfgyix51j
oZY7rKE8hG77ElVqzjKgYga+JTCNb9oKuzY73F44FKKA8sGGkscENN1ugXg4A/Jr
DrkhwGeDvXEeA8kHb2n/ptTUnxGUFR92S2yQkLjRlpizbbjD8Pvn2TtNXkG28PWs
EksanH8WFFkIxX4+CZUq9aiRlLurmwxlPZwXfskREh3AWYUiwN1Zu6FwTttSfzAB
UzuV7TQZiogKJW9GrugaBTag/MEDRyGgJY/FFziUUvbVDPSxItukWSfhRqhV4DcG
9fYxT6dsOYwfnreL3j1qZDLNc3+oPDwgne1Y6HnaCiJSMwFnNtIZ+3oFpct3Mr9a
qMtHw93XuEn8wT6nO8HWVCTZLfuafjzIMyCIMdrh8+Jb2aOmmVEKTPSt3dpKqaU6
jv8lxQQuJCY1TQ7tZlLrJkH7yL/z8+4Y+zf4PAPAfc3Mj21h6AIS7Terh0UqZAO1
KEb64pdldCmKzRu0TQTS1OQ+wAnwnvVlcq8dQB0XWChr1FsqZAYYHHdDuxRfLukh
gkDtGR7J+1+vHpfau0n/JEtVEn1hUwo762If7hwQifdfb/mkjWgIGYjg3C321Wrg
5mFZzhRt+F+djIo7NPINqIcuD+SWSCcpaVDiMeLjd6x1A9PI/b6hDgc+qYGwemh6
MIbjTpynwL4=
=+GKL
-----END PGP SIGNATURE-----

--=-MFIgs6Tdf/zYM+hIvEJP--


From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: gigaset: freeing an active object
Date: Sun, 29 Nov 2015 19:47:32 +0100
Message-ID: <565B4844.9020600@imap.cc>
References: <56587467.8050102@oracle.com> <565B1A1B.8020503@imap.cc>
 <565B4256.6080101@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="0VduxvwWnnqJlB5V5oR370MRbC72KdBXV"
Cc: pebolle@tiscali.nl, isdn@linux-pingi.de, davem@davemloft.net,
	gigaset307x-common@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>
To: Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:56023 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750756AbbK2Sre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 13:47:34 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id EA51E205F6
	for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 13:47:33 -0500 (EST)
In-Reply-To: <565B4256.6080101@hurleysoftware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0VduxvwWnnqJlB5V5oR370MRbC72KdBXV
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 29.11.2015 um 19:22 schrieb Peter Hurley:

>>> [  413.536749] WARNING: CPU: 6 PID: 25400 at lib/debugobjects.c:263 d=
ebug_print_object+0x1c4/0x1e0()
>>> [  413.538111] ODEBUG: free active (active state 0) object type: time=
r_list hint: delayed_work_timer_fn+0x0/0x90
>>
>> This message seems to indicate that an object of type timer_list was
>> freed which was still active. However the driver in question
>> (ser_gigaset) does not use any timers.
[...]
>> Judging from the backtrace below this must be the call
>>
>>         kfree(cs->hw.ser);
>>
>> in drivers/isdn/gigaset/ser-gigaset.c line 375.
>> cs->hw.ser is of type struct ser_cardstate *.
>> struct ser_cardstate consists of a struct platform_device, a struct
>> completion, an atomic_t and a pointer. No timer_list.
[...]
> The platform_device embedded in struct ser_cardstate hasn't been releas=
ed when
> you kfree() the memory it's in.

Btw I don't see a timer_list object in struct platform_device either.
Nor in the embedded struct device.

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--0VduxvwWnnqJlB5V5oR370MRbC72KdBXV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWW0hEAAoJEFPuqx0v+F+qan8H/jr6EpktXzJKI/ljPzj/E0EN
pj4YS64+g3hC5Gf7nw0622AXwjPsD2lOY0GCLossFPuh1Ybff8V0l73D2MVT4A23
Zm2zPScuzVJhEv/sLKgvO0HoYzdtn2+C3Na4kNqAOyWL2H+x1gIk20CEr5RNvfTv
Y7VP/kRbaS7pKGXLRub5oIM1dEqGlnTe6I2vd8Ht4tMT8A1k+eNII+QbBU6aSHOE
/LpOSsN6ZQIdkMH5pyZL269BG9AOjC1DUssVp8rwGaIKvtBGguA4L1WWGDO8lPyn
nv1qsY4w3dTtclyBrw8JiEM4RBAI//jd4FQaUUeQG5bm55uYrnWlFpT2n2oOIiM=
=HvPc
-----END PGP SIGNATURE-----

--0VduxvwWnnqJlB5V5oR370MRbC72KdBXV--

From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 1/8] isdn/gigaset: ratelimit CAPI message dumps
Date: Fri, 27 Apr 2012 12:29:36 +0200
Message-ID: <4F9A7510.5010808@imap.cc>
References: <20120425-patch-gigaset-00.tilman@imap.cc> <20120425-patch-gigaset-01.tilman@imap.cc> <4F98EDB1.5090702@b1-systems.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig8F741992D6CF69CD09BB719A"
Cc: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <keil@b1-systems.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:56559 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759231Ab2D0K3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 06:29:40 -0400
In-Reply-To: <4F98EDB1.5090702@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig8F741992D6CF69CD09BB719A
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Am 26.04.2012 08:39, schrieb Karsten Keil:
> Am 26.04.2012 01:02, schrieb Tilman Schmidt:
>> Introduce a global ratelimit for CAPI message dumps to protect
>> against possible log flood.
>> Drop the ratelimit for ignored messages which is now covered by the
>> global one.
>=20
> Hmm, I think the only CAPI messages which would need a ratelimit are
> related to the DATA_B3 messages. If you need CAPI debug messages in mos=
t
> cases you do not need all of the DATA_B3, but you do not want to miss
> any other message related to the call control. With a general rate limi=
t
> you do not have the control, which messages are logged and which are no=
t.

The ratelimit introduced by this patch only applies to messages
other than DATA_B3. Logging DATA_B3 messages is not done via
dump_cmsg().

I'd like to ratelimit specifically non-DATA_B3 messages because I
saw a (possibly buggy) CAPI application flooding the log with
FACILITY messages. Equally important, I'd like to make the
ratelimit in do_nothing() / do_unsupported() bursty because I had
a case where I needed to see several ignored/unhandled CAPI
messages in quick succession. So this patch is killing two birds
with one stone for me.

The burst limit of 20 messages in 20 seconds is chosen to allow a
complete call setup sequence to be logged, while limiting to one
message per second in the long run.

> And here maybe some cases, when even the DATA_B3 are important (e.g.
> searching bugs in flow control), so I would make it still conditional
> to allow to print all messages.

DATA_B3 dumps produce an enormous amount of log data and are
therefore controlled separately by the DEBUG_MCMD flag.
Someone who enables that should know what she or he does.
But if you need them, you need them all. A ratelimit doesn't
make sense there in my experience.

> And I'm not sure, if this is really something for stable.

It's pretty simple and localized, a net simplification, and only
affects generation of debugging messages, so I think it's safe.
But if you see a problem there I can drop the "CC: stable" line.

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)


--------------enig8F741992D6CF69CD09BB719A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk+adREACgkQQ3+did9BuFsvXwCeNQjoYNShl4J3+eQj6H+UQqRa
jRwAnAjVIdpizcmJyGnfTWi2wDowWJFm
=gL8t
-----END PGP SIGNATURE-----

--------------enig8F741992D6CF69CD09BB719A--

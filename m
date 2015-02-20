From: Simon Farnsworth <simon@farnz.org.uk>
Subject: Re: [PATCH] pppoe: Use workqueue to die properly when a PADT is received
Date: Fri, 20 Feb 2015 21:04:53 +0000
Message-ID: <2335170.7Jqfc2NRFK@hummingbird.farnz.org.uk>
References: <1424381068-22252-1-git-send-email-simon@farnz.org.uk> <2498181.kKNYHvd3hx@f19simon> <20150220204923.13275ydcca5wwwcj@berry.schulz.ip-v6.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart5098787.67mfqJgTrn"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	mostrows@gmail.com, linux-ppp@vger.kernel.org
To: Christoph Schulz <develop@kristov.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from logos.farnz.org.uk ([93.93.135.63]:56675 "EHLO
	logos.farnz.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432AbbBTVFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 16:05:01 -0500
In-Reply-To: <20150220204923.13275ydcca5wwwcj@berry.schulz.ip-v6.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart5098787.67mfqJgTrn
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

On Friday 20 February 2015 20:49:23 Christoph Schulz wrote:
> Hello!
>=20
> Simon Farnsworth schrieb am Fri, 20 Feb 2015 16:41:17 +0000:
> >> Feb 20 16:45:44 sandbox local2.err pppd[539]: Failed to disconnect=

> >> PPPoE socket: 114 Operation already in progress
> >=20
> > I assume there's nothing else wrong here, other than pppd complaini=
ng? The
> > code doesn't suggest there will be issues if we fail to disconnect.=

>=20
> Yes, there are no further problems beside the message. Nevertheless I=

> wanted to mention it because any error message containing something
> like "Failed to disconnect" may upset the user. Of course, most PPPoE=

> users nowadays use a flat rate for accessing the Internet and need no=
t
> worry much about a "failed" disconnection, but you never know for
> sure...
>=20
I've now looked at the kernel code; the message is harmless, as closing=
 the=20
socket will also get rid of the associated session.

However, I think I should probably do a v2 patch with a clear commit me=
ssage,=20
so that if someone does bisect down to this commit as a cause of the "e=
rror"=20
they're seeing, they'll understand why it's not a problem.

I'll also put together a pppd patch to not change session ID during shu=
tdown.=20
Won't be tonight - but that's no bad thing as it leaves time for more=20=

reviewers to comment on my kernel patch.
=2D-=20
Simon Farnsworth
--nextPart5098787.67mfqJgTrn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABAgAGBQJU56F4AAoJEIX5k7RAOWS210YH/02szSFmpZTBtAZFBnAvV3fQ
nOPu5f576KLq5p9zB+O6BUUE4dxFC0wuWHg8wC4IMnMIAilzJE1qfTcFK/xZeQY6
QnfjsBYh3abjmAugMcw9uaQox9j33017sM4+j+Uw9HQd3fABRo3WuRbabPpU3KC7
olTlqdg0ybkhnMobdaS/yyZLOm9NoVJzSc5GnQKJ8IqNCINeA+AxXFnKQSC92f87
+G9FhXjk5OxrmKlQRTtY9B6C5Jw0HfnpF1n3QFc+PfHzc7INkVk4C2xROBNAguWg
WmMw0Ak5DQhSpKx6QqMb3JnqUdciU9jriwcpuFM1mwNsytCNWs27Pf9cwXvtkO4=
=xZ5m
-----END PGP SIGNATURE-----

--nextPart5098787.67mfqJgTrn--

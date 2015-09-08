From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 3/3] r8169: increase the lifespan of the hardware
 counters dump area.
Date: Tue, 8 Sep 2015 10:05:12 +0200
Message-ID: <20150908080512.GF20288@calimero.vinschen.de>
References: <20150906103732.GF30539@calimero.vinschen.de>
 <20150906202153.GB19371@electric-eye.fr.zoreil.com>
 <20150907092949.GH30539@calimero.vinschen.de>
 <20150907.170058.1837760587790956754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="orO6xySwJI16pVnm"
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	pomidorabelisima@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:42311 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369AbbIHIFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 04:05:16 -0400
Content-Disposition: inline
In-Reply-To: <20150907.170058.1837760587790956754.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--orO6xySwJI16pVnm
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi David,

On Sep  7 17:00, David Miller wrote:
> From: Corinna Vinschen <vinschen@redhat.com>
> Date: Mon, 7 Sep 2015 11:29:49 +0200
>=20
> > Still wondering though.  Given that the driver never failed before if
> > the counter values couldn't be updated, and given that these counter
> > values only have statistical relevance, why should this suddenly result
> > in a fatal failure at open time?
>=20
> Failing to allocate such a small buffer means we have much deeper issues
> at hand.  A GFP_KERNEL allocation of this size really should not fail.

I'm not talking about the allocation.  I agree with you on that score.

What I'm talking about is the situation where the NIC hardware fails to
reset or update its own counters for whatever reason.  Apparently the
mechanism is supposed to be performed within a given timeframe.  The
code sets some registers and then waits for a flag bit to be set to 0.
For that it utilizes a busy loop checking the flag bit up to 1000 times
with a delay of about 10 us.

The error condition is that the flag bit hasn't been set to 0 when the
loop exits, after roughly 10ms, and *this* part does not constitute a
fatal error which breaks the operation of the NIC.  So, from my
perspective a timeout while trying to wait for updated counter values
=66rom the NIC at @ndo_open time should not be treated as fatal.


Corinna

--orO6xySwJI16pVnm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV7pa4AAoJEPU2Bp2uRE+gwn4QAKFIDzPAGUtgpRHv2JnqQ9S2
zAbgNpLScA5gCDaE7C6KZ0Fi+G0+bwacgsMxpwtqw0MapRvUBveUwVH+1Te2H2BL
FqSltU3LqZGvaztl4qZQhu+ZFLgK8B75cH8MqfiEs/okl5Ma0kCs0mfopYIjgWZh
jfa190MO3IajLoaq0YP0IyUkN72UDYP4JFcvyGSwPxXETedztGet9wSVBDjHImRe
ualnuvquEH5LLMSFQGi+K6Y6uTehZx3/FEGiQb8aTAIHVS773+b96745oGGpdGhq
CzFOpdRi0kUC4ib06K9WkS2j0ZLVRtk8ZWEH5R/+DZpB5codcbrEVkXwMEUFtP6x
SVo5giQv0scLIbS/Y8GLgvZ0OJaXdeOYXR+DskyzdcJzLF8CEYhS63/FfQljmspD
x74KJCRodvxkVF3Z79YyKPguGrLIpFcQ3QwlIhpLPVO8Vde5V6TQnbksTYuWYZVX
dYrQPGujJDJZpAzR/3S+xq6kD+SKgebGcqr4T75fAGmgOKPKjEy32ILFmzMv9X1/
aAcX5nkY9q8znLOuf2Y6/Wz4ZiFkCWYkXLx9f9RElEw0YRKvX4yTugrb+KUD012h
4R6NEhw8J37d9gPIzApDy9TffdTykaQak6bRxN6pNaREFPftvXCIqeUeU3Rkmt+x
tWStq7Y6+L5sKdcYT4DI
=PnwH
-----END PGP SIGNATURE-----

--orO6xySwJI16pVnm--

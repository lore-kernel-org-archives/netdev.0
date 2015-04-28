From: Mihai Moldovan <ionic@ionic.de>
Subject: Re: iproute2 regression -- ss -u returns an empty list
Date: Tue, 28 Apr 2015 07:07:56 +0200
Message-ID: <553F15AC.3080606@ionic.de>
References: <553EE0D9.3050601@ionic.de> <20150428040516.GA14129@angus-think.lan> <553F0D8E.9060602@ionic.de> <20150428044708.GA22671@angus-think.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="QoXlc9XeUQBmvMGR32iVJHWtOUpjv4Evd"
Cc: netdev@vger.kernel.org, Bernard Cafarelli <voyageur@gentoo.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from powered.by.root24.eu ([5.135.3.88]:54763 "EHLO Root24.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750970AbbD1FIF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 01:08:05 -0400
In-Reply-To: <20150428044708.GA22671@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QoXlc9XeUQBmvMGR32iVJHWtOUpjv4Evd
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 28.04.2015 06:47 AM, Vadim Kochan wrote:
> On Tue, Apr 28, 2015 at 06:33:18AM +0200, Mihai Moldovan wrote:
>> On 28.04.2015 06:05 AM, Vadim Kochan wrote:> So by default ss prints
>> socket with CONNECTED state and even UDP can be
>>> in the CONNECTED state on the Linux,
>>=20
>> UDP can be in a CONNECTED state... ooookay. That's probably a conntrac=
k=20
>> thing.
>>=20
>>=20
>>> so you can specify 'ss -ua' (may be some explanation should be added =
to=20
>>> the ss man page) which should print UDP sockets in the any state, AFA=
IK=20
>>> it was the default behaviour before my changes.
>>=20
>> Could this please be reverted? It's breaking other stuff that uses ss.=

>>=20
>> Also: ss -lxua returns an empty list, too. Previously, the families se=
em
>> to have been OR'd, while they are now ANDed?
>>=20
>>=20
>>=20
>> Mihai
>>=20
>=20
> I will try to fix this ...

Thanks!

To be a bit more verbose about the rationale:

Changing the default behavior is generally a bad idea, unless strictly ne=
cessary
(e.g., if the previous default behavior was buggy anyway), because it may=
 break
other software. Please try introducing behavioral changes via new options=
=2E

That way, dependencies will still work fine and anyone who wants to use t=
he new
behavior can explicitly do so via a switch.

I could work around this by checking ss' version, but that turns out to b=
e a
pain, too, because ss -V reports something like this:

"ss utility, iproute2-ss150413"

Not exactly a "friendly" version like "3.19.0" or "4.0.0" to check agains=
t...



Mihai



--QoXlc9XeUQBmvMGR32iVJHWtOUpjv4Evd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJVPxWsAAoJEB/WLtluJTqHSC4P+gN1nvq3qcTa+6llXYWv6UK6
4IgbwrFeF2Alv2DxTblVlwQBYz6AG8no1YvenlOAkhG1q2JF+fzuRMCQ9Lf9NsaN
Pj9dSNll/bIaPsRPzWCKoCCfoEyj49faO/+toqKbFgJA4YmBlFQM32oahb3woFyC
B0nT8tH1S9QXYuLZSx3c4LRZtbDsV0a9o85KLgOMPw/FRU3oVKcP5nfbA3C0orlo
vv+6KVPJ/dsxm1VFsTnD2d7TExuONm0lJOfHH7EfDnZwabT3optFNhbqyWzfoglo
ZUqB4zDz8VFjJ+zDqFNf27WmKgzedFlMIUzvK5qVVLqmO/76X0uduq3HL4M0/EXR
MuHkTZNf9U+LrhLyc8NLnNRtC/gTEKpF9b0mHZkn1wACm/SpgKKv6RFLx1RN2S7k
qZDFcENxwBf/RV13HhuihEgF0pl6KPtXSW6mRPNcLlDIuxKxNBooIUQOXNOKUXN4
7oYaL7x2r8/yvGg4KjNp/XdYu1F6TpEZqN1VMyUSo5yNjZURdxlj8KBzSp2LavFV
TEksoJmfSEhB5jZluQRzEYdvY2jAEY6k7iphINkKpjDIEyUCmikDkQRz0MPHmKjN
t0Qepsx9OmHwg4x6/Q7ayJc8G8Nk0sgM54gNGMjZWEbr/R5B+VPjoNyUUslvni0o
7POaPhd91gVhRLXq8utf
=dkFc
-----END PGP SIGNATURE-----

--QoXlc9XeUQBmvMGR32iVJHWtOUpjv4Evd--

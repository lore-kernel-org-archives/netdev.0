From: "Andrew O. Shadoura" <bugzilla@tut.by>
Subject: Re: suspend warning with 3c59x
Date: Tue, 14 Sep 2010 18:52:24 +0300
Message-ID: <201009141852.24775.bugzilla@tut.by>
References: <4C8F9598.60309@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1563074.vZnYPHiWk5";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Denis Kirjanov <dkirjanov@kernel.org>, ben@decadent.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:36513 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149Ab0INPw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 11:52:27 -0400
Received: by iwn5 with SMTP id 5so6180150iwn.19
        for <netdev@vger.kernel.org>; Tue, 14 Sep 2010 08:52:26 -0700 (PDT)
In-Reply-To: <4C8F9598.60309@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1563074.vZnYPHiWk5
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Hello.

On Tuesday 14 September 2010 18:32:40 you wrote:
> I have got a warning with the 3c59.
> (reproduced with pm-suspend)
>=20
> [  254.214993] 3c59x 0000:00:0d.0: PME# enabled
> [  254.215021] BUG: sleeping function called from invalid context at
> kernel/mutex.c:94
> [  254.215030] in_atomic(): 0, irqs_disabled(): 1, pid: 4875, name: ethto=
ol
> [  254.215042] Pid: 4875, comm: ethtool Tainted: G   =20
>    W   2.6.36-rc3+ #7 [  254.215049] Call Trace:
=20
> Warning introduced with commit 690a1f2002a3091bd18a501f46c9530f10481463:
> 3c59x: Add ethtool WOL support

> vortex_set_wol protected with a spinlock, but nested  acpi_set_WOL acquir=
es
> a mutex inside atomic context. Do we really need to protect .set_wol with
> a vp->lock at all?

Yes, that was my mistake, we do not actually need it.

=2D-=20
WBR, Andrew

--nextPart1563074.vZnYPHiWk5
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkyPmjgACgkQ/mQMD2bMZ2siRgCfRDGmR0Cc1u9chkIyYEXFVzsC
Z6AAn1C4aCmNGpGqh2Mb3Axt6LWTJlDT
=0QYg
-----END PGP SIGNATURE-----

--nextPart1563074.vZnYPHiWk5--

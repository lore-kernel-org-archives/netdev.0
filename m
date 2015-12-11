From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH v2] r8169: Don't claim WoL works if LanWake flag is not
 set
Date: Fri, 11 Dec 2015 10:42:29 +0100
Message-ID: <20151211094229.GC3507@calimero.vinschen.de>
References: <1449655730-3328-1-git-send-email-vinschen@redhat.com>
 <1449657826-4461-1-git-send-email-vinschen@redhat.com>
 <20151209224306.GA5082@electric-eye.fr.zoreil.com>
 <20151210095135.GA21583@calimero.vinschen.de>
 <20151210204054.GA30391@electric-eye.fr.zoreil.com>
 <20151210220255.GB3507@calimero.vinschen.de>
 <20151211000627.GA3705@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="S1BNGpv0yoYahz37"
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Chun-Hao Lin <hau@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Corinna Vinschen <vinschen@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:35322 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754413AbbLKJmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 04:42:33 -0500
Content-Disposition: inline
In-Reply-To: <20151211000627.GA3705@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--S1BNGpv0yoYahz37
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Dec 11 01:06, Francois Romieu wrote:
> Corinna Vinschen <vinschen@redhat.com> :
> [...]
> > It's still a bit weird.  On the machines I tested this on, if I disable
> > LanWake and shutdown the machine, I can send, e.g., MagicPackets as much
> > as I like, the machined don't come up.  Isn't it a bit misleading then
> > if ethtool reports that some WoL method is enabled but it doesn't work?
>=20
> Of course it is. :o(
>=20
> I'm fine with Config5.LanWake changes if you have empirical evidences that
> it helps.
>=20
> We have terse - outdated ? - documentation and some hint from
> http://marc.info/?l=3Dlinux-netdev&m=3D137654699802446. I'm unable to fig=
ure
> what an/the adequate change could be, especially a low level chance of
> regression one.

I think the problem here is that LanWake only switches off aspects of
the WoL capability which can't be reflected in a reliable way to the
kernel.  That's certainly one reason for the driver to enable/disable
LanWake always in lock-step with PMEnable.

So I wonder if we shouldn't just add some code to rtl_init_one (or
create a new function called from rtl_init_one) which checks the WoL
flags and if the PmConfig and LanWake flags are set inconsistently
(aka "differently") then set them to an equal value, either 0 (no WoL
method enabled) or 1 (any WoL method enabled).

Does that make sense?


Thanks,
Corinna

--S1BNGpv0yoYahz37
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWapqFAAoJEPU2Bp2uRE+gWpUQAIfv/txTuc05S7NFIcS7eOij
vXcq7sFlzZDlx+5rDxRXfr3C/66taP5rAJlgi+GJYE212khv8Yk2ksNKYNyFLOu8
rVKEE3I+UspCmQKyO83UuWy7WBPhnXAOnAMnwwGbmd4t3428H8ycABzMcyUJgOXo
UtD1nmIu+oAJ0E88tntxG29Sermx0F2UtDpzx+T28NriA5N0RRBvwh14gtK7AItT
MsoVG48yRNC7TvDtotDaI8jM+f3FjQEwHIbIiOfQKZ8QzOw5HqahEPWcklTXLlnI
ozLuVTJcZ7+Cyf6+qY0OJpG2BxEQvpcUSZ+wOodIsAAZjUOxy/X6/0p7hsQQuvGY
3skAWy1npOdk0doNVeV1x9yNOQGQU8VrrakXkC1klhNb3N7HO2TNwjjUtRZBzXpz
tK8izZIwErQbNcYfoReZ50UEqW/KnLk6t11cdbIT9JeJzuhj6Wxbj/iIjadeajp8
iDAoPQfGuE6omtdN3x4N3JIT+GeFs3NKGD6gIDo5CJwuksS5UHyflP9ZcMam2ri9
9O54nN9USt6TItzTHRU+5N/mx0HmvXxd7IquZ6QGUT0uF+NT2fgFMs5YlV6wJacD
MZzeNAKO3S+cAgzLayDaojZJqLIY6ZO/fNYFtJgutgaNkCueG/5M1JcHFfVDJo8h
EzR+vyrh6LJJa8QE/OfD
=fXnq
-----END PGP SIGNATURE-----

--S1BNGpv0yoYahz37--

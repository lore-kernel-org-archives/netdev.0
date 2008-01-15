From: Radoslaw Szkodzinski (AstralStorm) <lkml@astralstorm.puszkin.org>
Subject: Re: questions on NAPI processing latency and dropped network
 packets
Date: Tue, 15 Jan 2008 16:17:05 +0100
Message-ID: <20080115161705.0724250d@astralstorm.puszkin.org>
References: <20080115071950.GA1696@ff.dom.local>
	<478CC76B.1020804@nortel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/8tJObg510IBp.7DfwEaB7GX";
 protocol="application/pgp-signature"; micalg=PGP-SHA1
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chello089077127128.chello.pl ([89.77.127.128]:45659 "EHLO
	astralstorm.puszkin.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbYAOPXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 10:23:44 -0500
In-Reply-To: <478CC76B.1020804@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/8tJObg510IBp.7DfwEaB7GX
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 15 Jan 2008 08:47:07 -0600
"Chris Friesen" <cfriesen@nortel.com> wrote:

> Jarek Poplawski wrote:
>=20
> > IMHO, checking this with a current stable, which probably you are going
> > to do some day, anyway, should be 100% acceptable: giving some input to
> > netdev, while still working for yourself.
>=20
> While I would love to do this, it's not that simple.
>=20
> Some of our hardware is not supported on mainline, so we need per-kernel=
=20
> version patches to even bring up the blade.  The blades netboot via a=20
> jumbo-frame network, so kernel extensions are needed to handle setting=20
> the MTU before mounting the rootfs.

Why? Can't you use a small initramfs to set it up?

> The blade in question uses CKRM=20
> which doesn't exist for newer kernels so the problem may simply be=20
> hidden by scheduling differences.

Current spiritual successor is Ingo's realtime patchset I guess.

> The userspace application uses other=20
> kernel features that are not in mainline (and likely some of them won't=20
> ever be in mainline--I know because I've tried).

What would these be? Some proc or sysfs files that were removed or
renamed?
Maybe they can be worked around w/o changing the application at all, or
very minor changes.

Also, be sure to check if there are pauses with other CPU hogs.

> Basically, the number of changes required for our environment makes it=20
> difficult to just boot up the latest kernel.

Yes, adding an initramfs is non-trivial (some busybox + shell
scripting), but not all that hard either.
And maintaining one is easier than patching the kernel.
(usually 0 maintenance, maybe minor fixes sometimes)

--Sig_/8tJObg510IBp.7DfwEaB7GX
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.8 (GNU/Linux)

iEYEARECAAYFAkeMznoACgkQBlhXA0ALOYMwvACgkLIEPeMlYnCDE/ylqXZl+OU2
TkgAnR1FlNKBsGNvJhPY+hbbawXi5dEh
=T8Zj
-----END PGP SIGNATURE-----

--Sig_/8tJObg510IBp.7DfwEaB7GX--

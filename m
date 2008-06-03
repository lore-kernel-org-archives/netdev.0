From: Bas Wijnen <wijnen@debian.org>
Subject: Re: non-root, non-real network manipulation for netconf testing
Date: Tue, 3 Jun 2008 19:43:57 +0200
Message-ID: <20080603174357.GB15355@a82-93-13-222.adsl.xs4all.nl>
References: <20080603080529.GA9010@lapse.madduck.net> <20080603100513.GA18161@solarflare.com> <20080603102050.GA14461@lapse.madduck.net> <20080603080529.GA9010@lapse.madduck.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="qlTNgmc+xy1dBmNv"
Cc: netdev discussion list <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netconf developers list <netconf-devel@lists.alioth.debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr16.xs4all.nl ([194.109.24.36]:3070 "EHLO
	smtp-vbr16.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbYFCRzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 13:55:06 -0400
Content-Disposition: inline
In-Reply-To: <20080603102050.GA14461@lapse.madduck.net> <20080603080529.GA9010@lapse.madduck.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qlTNgmc+xy1dBmNv
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Jun 03, 2008 at 10:05:29AM +0200, martin f krafft wrote:
> Of course, I am asking a bit much, but maybe you guys have some
> input that could help us move along?

The best way would be to use the Hurd, and write a network device
emulator (which can be modified without messing up actual network
devices).  But I suppose that's not an option. ;-)

As a second option, I'd go for qemu.  It can be run as non-root and
communicate about its test results over the serial port (connected to
stdout).  However, building a qemu image takes a long time, and I think
you still need root for that.

> What I really want is some context handler that can emulate
> a complete network and process stack for my test scripts, let
> a normal user modify anything they want, but not touch anything on
> the actual system.

Qemu does all that, it emulates a whole computer with it. :-)

On Tue, Jun 03, 2008 at 12:20:50PM +0200, martin f krafft wrote:
> also sprach Ben Hutchings <bhutchings@solarflare.com> [2008.06.03.1205 +0=
200]:
> > Have you considering running the tests in User-Mode Linux or some
> > other kind of virtualised environment?
>=20
> Yes, but that would require root rights as well, and quite a lot of
> setup, making it pretty unlikely that passerby developers would run
> tests, or allowing me to run the tests automatically on build
> daemons.

You can do all the setup automatically, so passerby developers don't
need to know how to do it.  However, the root rights (or, in case of
qemu, the heavy setup process) does probably make it impractical to do
it on a buildd, for example.

An option would be to create a dummy network device of the type I
described for the Hurd, but for Linux, and package that in a separate
package.  Netconf can build-depend on it, so it is installed (and can
make sure it is available for normal users).

However, I don't think Linux allows network interfaces to tell that
normal users may modify them...

Thanks,
Bas

--=20
I encourage people to send encrypted e-mail (see http://www.gnupg.org).
If you have problems reading my e-mail, use a better reader.
Please send the central message of e-mails as plain text
   in the message body, not as HTML and definitely not as MS Word.
Please do not use the MS Word format for attachments either.
For more information, see http://pcbcn10.phys.rug.nl/e-mail.html

--qlTNgmc+xy1dBmNv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIRYLcFShl+2J8z5URAmj+AKCm0csvMO+xyv6QDyHxHvVW6ZKAoACfRjbf
D/JUT8LhiDKGXqtPkYVWlnk=
=rTKB
-----END PGP SIGNATURE-----

--qlTNgmc+xy1dBmNv--

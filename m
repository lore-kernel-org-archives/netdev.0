From: Felipe Balbi <balbi@ti.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Tue, 30 Dec 2014 17:22:23 -0600
Message-ID: <20141230232223.GD415@saruman>
References: <CAGm1_ksziwSjQnV1rDYsAv2QQCvhnZPOimowmsW5Cib7C01aqA@mail.gmail.com>
 <20141210210234.GN4602@saruman>
 <CAGm1_ktYg4iDgK7jyi5etSVup61LdookkV+SaQZOpLb6M=y7hA@mail.gmail.com>
 <CAGm1_kuaqXrU4zhNUZeY85+OeXHApSUDjJdsXcyBdvHTNhLCmQ@mail.gmail.com>
 <20141212173210.GI7549@saruman>
 <CAGm1_kuYrGsfjRO6TVr554yS8dcD4_Z9-j9KL0xpD=X+31OkXQ@mail.gmail.com>
 <CAGm1_kudtF9O4QChrKX1q=c9KwHEFZet=z7j=-_iCRE914X83Q@mail.gmail.com>
 <20141229155029.GA29379@saruman>
 <20141229165103.GB2411@atomide.com>
 <20141229171355.GJ29379@saruman>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d9ADC0YsG2v16Js0"
Cc: Tony Lindgren <tony@atomide.com>,
	Yegor Yefremov <yegorslists@googlemail.com>,
	netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Felipe Balbi <balbi@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141229171355.GJ29379@saruman>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--d9ADC0YsG2v16Js0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, Dec 29, 2014 at 11:13:55AM -0600, Felipe Balbi wrote:
> > > > >>> U-Boot version: 2014.07
> > > > >>> Kernel config is omap2plus with enabled USB
> > > > >>>
> > > > >>> # cat /proc/version
> > > > >>> Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
> > > > >>> 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6=
 SMP
> > > > >>> Mon Dec 8 22:47:43 CET 2014
> > > > >>
> > > > >> Wasn't GCC 4.8.x total crap for building ARM kernels ? IIRC it w=
as even
> > > > >> blacklisted. Can you try with 4.9.x just to make sure ?
> > > > >
> > > > > Will do.
> > > >=20
> > > > Adding linux-omap. Beginning of this discussion:
> > > > http://comments.gmane.org/gmane.linux.network/341427
> > > >=20
> > > > Quick summary: starting with kernel 3.18 or commit
> > > > 55601c9f24670ba926ebdd4d712ac3b177232330 am335x (at least BBB and s=
ome
> > > > custom boards) stalls at high network load. Reproducible via nuttcp
> > > > within some minutes
> > > >=20
> > > > nuttcp -S (on BBB)
> > > > nuttcp -t -N 4 -T30m 192.168.1.235 (on host)
> > > >=20
> > > > As Felipe Balbi suggested, I tried both 4.8.3 and 4.9.2 toolchains,
> > > > but both show the same behavior.
> > > >=20
> > > > Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
> > > > 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6 SMP
> > > > Mon Dec 8 22:47:43 CET 2014
> > > > Linux version 3.18.1 (user@user-VirtualBox) (gcc version 4.9.2
> > > > (Buildroot 2015.02-git-00582-g10b9761) ) #1 SMP Mon Dec 29 09:22:29
> > > > CET 2014
> > > >=20
> > > > Let me know, if you can reproduce this issue.
> > >=20
> > > finally managed to reproduce this, it took quite a bit of effort thou=
gh.
> > > I'll see if I can gether more information about the problem.
> >=20
> > Maybe check if the irqnr is 127 (or the last reserved interrupt)
> > in irq-omap-intc.c. If so, also print out the previous interrupt.
> > It seems the intc uses the last reserved interrupt to signal a
> > spurious interrupt for the previous irqnr, so we should probably
> > add some handling for that.
> >=20
> > If the previous interrupt is a cpsw interrupt, then there's probably
> > something wrong with cpsw interrupt handling. Either a missing
> > read-back to flush posted write in the cpsw interrupt handler,
> > or the EOI registers are written at a wrong time.
>=20
> yeah, I'll go over it, but I first need to reproduce it again. Just
> rebooted to try again and after half an hour, couldn't reproduce it
> anymore. Interesting race to end the year :-)

alright, managed to reproduce multiple and I'm pretty confident I've
found the bug. Right now I'm testing with AM437x and AM335x to make sure
it's really working. If it's still running until tomorrow I'll send a
preliminary patch but I want to leave this running for quite a few days
before calling it "fixed".

--=20
balbi

--d9ADC0YsG2v16Js0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUozOvAAoJEIaOsuA1yqREh6cP/inK4r9ekju3+RyKLB65jmxf
sf1qlh650SXSTlh+KqbDJPtJ3NbDfXF/SYaVFJNcKYA0H1wELYe0j6PjP/qfHZdl
re8pM/eM56P588F/qLb8iwVFwh086s6KwsiFUoxkoI7+UvRF/LZ4dGdbO4B6znZ2
yydh+lmZWCBNtA4SrSvjwUMOWGnBagK5adhvJmtCXrB4da4DySgf2IEFo+AZpyfX
YmOjJTLG1zoX4hLlUfdeoeKDbMzZNj+LsJ87zzGCfN+ms/1hIhq4bN5TlqdNKBFN
Ff6R8PMwYUrf9bnac4QGZ2v/AfdV7dMsWLYc9VjSEOVAqQIC8PFvS3dqaQa2imV3
iDC++9BYp2qKD3gHL0JG5C71aOAfDDPRm1W0LCY6kMJ68XklFlRfWxDFZ+GfjnHy
A/UvKXhcpnxQBppP31p1Zz3HwDq7/IXUSUyh6h8yTsH+vQx+3c4/0A5gdMXE5yFH
4/j/SLuu1mJCPN+/9t8lrdHdB/gm+fm1sfjJAG55kr82xyBIHPynQ5eorVXIuIoK
hbMUMewOc9vGQoStSxx00DITBmZZRI1s1sW6Ye4nD9FB8wMocRr/3p0h0XhwFIDa
+xiia9k7ksKInG8BjMVwenheKO9SkKcHgbQX4fxkgRilJ4RPweoJjv27a0JZcVbC
gip8pyzwNXKMBRPfgC+c
=lbwh
-----END PGP SIGNATURE-----

--d9ADC0YsG2v16Js0--

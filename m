From: Felipe Balbi <balbi@ti.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Mon, 29 Dec 2014 11:13:55 -0600
Message-ID: <20141229171355.GJ29379@saruman>
References: <20141210171724.GI4602@saruman>
 <CAGm1_ksziwSjQnV1rDYsAv2QQCvhnZPOimowmsW5Cib7C01aqA@mail.gmail.com>
 <20141210210234.GN4602@saruman>
 <CAGm1_ktYg4iDgK7jyi5etSVup61LdookkV+SaQZOpLb6M=y7hA@mail.gmail.com>
 <CAGm1_kuaqXrU4zhNUZeY85+OeXHApSUDjJdsXcyBdvHTNhLCmQ@mail.gmail.com>
 <20141212173210.GI7549@saruman>
 <CAGm1_kuYrGsfjRO6TVr554yS8dcD4_Z9-j9KL0xpD=X+31OkXQ@mail.gmail.com>
 <CAGm1_kudtF9O4QChrKX1q=c9KwHEFZet=z7j=-_iCRE914X83Q@mail.gmail.com>
 <20141229155029.GA29379@saruman>
 <20141229165103.GB2411@atomide.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQAwcd5tHl0Qlnzi"
Cc: Felipe Balbi <balbi@ti.com>,
	Yegor Yefremov <yegorslists@googlemail.com>,
	netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141229165103.GB2411@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--LQAwcd5tHl0Qlnzi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 29, 2014 at 08:51:04AM -0800, Tony Lindgren wrote:
> * Felipe Balbi <balbi@ti.com> [141229 07:53]:
> > On Mon, Dec 29, 2014 at 10:33:26AM +0100, Yegor Yefremov wrote:
> > > On Fri, Dec 12, 2014 at 8:19 PM, Yegor Yefremov
> > > <yegorslists@googlemail.com> wrote:
> > > > On Fri, Dec 12, 2014 at 6:32 PM, Felipe Balbi <balbi@ti.com> wrote:
> > > >> Hi,
> > > >>
> > > >> On Fri, Dec 12, 2014 at 01:00:51PM +0100, Yegor Yefremov wrote:
> > > >>> U-Boot version: 2014.07
> > > >>> Kernel config is omap2plus with enabled USB
> > > >>>
> > > >>> # cat /proc/version
> > > >>> Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
> > > >>> 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6 S=
MP
> > > >>> Mon Dec 8 22:47:43 CET 2014
> > > >>
> > > >> Wasn't GCC 4.8.x total crap for building ARM kernels ? IIRC it was=
 even
> > > >> blacklisted. Can you try with 4.9.x just to make sure ?
> > > >
> > > > Will do.
> > >=20
> > > Adding linux-omap. Beginning of this discussion:
> > > http://comments.gmane.org/gmane.linux.network/341427
> > >=20
> > > Quick summary: starting with kernel 3.18 or commit
> > > 55601c9f24670ba926ebdd4d712ac3b177232330 am335x (at least BBB and some
> > > custom boards) stalls at high network load. Reproducible via nuttcp
> > > within some minutes
> > >=20
> > > nuttcp -S (on BBB)
> > > nuttcp -t -N 4 -T30m 192.168.1.235 (on host)
> > >=20
> > > As Felipe Balbi suggested, I tried both 4.8.3 and 4.9.2 toolchains,
> > > but both show the same behavior.
> > >=20
> > > Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
> > > 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6 SMP
> > > Mon Dec 8 22:47:43 CET 2014
> > > Linux version 3.18.1 (user@user-VirtualBox) (gcc version 4.9.2
> > > (Buildroot 2015.02-git-00582-g10b9761) ) #1 SMP Mon Dec 29 09:22:29
> > > CET 2014
> > >=20
> > > Let me know, if you can reproduce this issue.
> >=20
> > finally managed to reproduce this, it took quite a bit of effort though.
> > I'll see if I can gether more information about the problem.
>=20
> Maybe check if the irqnr is 127 (or the last reserved interrupt)
> in irq-omap-intc.c. If so, also print out the previous interrupt.
> It seems the intc uses the last reserved interrupt to signal a
> spurious interrupt for the previous irqnr, so we should probably
> add some handling for that.
>=20
> If the previous interrupt is a cpsw interrupt, then there's probably
> something wrong with cpsw interrupt handling. Either a missing
> read-back to flush posted write in the cpsw interrupt handler,
> or the EOI registers are written at a wrong time.

yeah, I'll go over it, but I first need to reproduce it again. Just
rebooted to try again and after half an hour, couldn't reproduce it
anymore. Interesting race to end the year :-)

cheers

--=20
balbi

--LQAwcd5tHl0Qlnzi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUoYvTAAoJEIaOsuA1yqREx1kP/iT4BVpdW2f5xp4HnBFC2mlC
XZNCfAoBTXTzY+aKMy9xM+oiNWeUc7UR5/zmNZepFkEQvKIqT5hcVxYH0ThT1/b3
/UrFFRZD45/tWuH7RlgDAO9/mrSkXiHE/CyUKPf6yVNiL4yCzQcbkdWV1r91P+i6
TSIzAr0TWnVx8Bv3895k0/Fu9f93j5WzI9QdvkOXxGBN+KKprsfoS8lg2I7hLoiG
v3g6lbYJvSc14nvLgupVeENfR1z3BBKEam4CDNqP3hcGcd6yFGnwZnjM/Qctr/aE
3sHD/RWc+LafDUjU5ET0i9TPwg5d+UV5PS77WwVEvFyjh2y0/mijz32+RE1AkFxg
7qXotgJKbly0h5BggOxpM42HxIrHFsL6CClMIyo+XFKUGm5sv+LRBK/BlSv2ByYg
YT7wQQaJaAEpHI7oHk15qWuGXMSy1kkm/Y82flEb2wR7eg6qxEGWuuwcZS491aKu
dZoWKkZL9xSdI1UTS4I1SF6Xe1EmQHMbZOAkt0bHJmDHPHl8MMPB9uaDNR2wfqLO
hqScp6tsvH5waT4ekmD/WLqzswGNVMM6tJOw8AGf3TTkzALIBYhcxHGwhA1JRDiS
nKaVHs95LgQCnD/234ety3cOzcqvV5dhoZ8aDi4RhsCVVrSyGagSZz5RExHa2J/H
2xfw8dtsQjnXL4cAWDOP
=uZxW
-----END PGP SIGNATURE-----

--LQAwcd5tHl0Qlnzi--

From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Wed, 23 Nov 2016 23:39:59 +0100
Message-ID: <201611232339.59411@pali>
References: <201611111820.52072@pali> <201611221805.13606@pali> <20161123222335.GA4788@amd>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1899648.o0QrnXPIW8";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Michal Kazior <michal.kazior@tieto.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Sebastian Reichel <sre@kernel.org>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        "linux-wireless" <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161123222335.GA4788@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1899648.o0QrnXPIW8
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Wednesday 23 November 2016 23:23:35 Pavel Machek wrote:
> Hi!
>=20
> > > > As wl1251.ko does not accept mac_address as module parameter,
> > > > such modprobe hook does not help -- as there is absolutely no
> > > > way from userspace to set or change (permanent) mac address.
> > >=20
> > > Quoting modprobe.d manual:
> > > >       install modulename command...
> > > >      =20
> > > >           This command instructs modprobe to run your
> > > >           command instead of inserting the module in the
> > > >           kernel as normal. The command can be any shell
> > > >           command: this allows you to do any kind of
> > > >           complex processing you might wish. [...]
> >=20
> > I know. But this do not allow me to send mac address to kernel --
> > as kernel does not support such command yet (reason for my first
> > question).
>=20
> Plus, this does not really work for cases where wl1251 is not a
> module.

Yes, this is another problem.

> > > You can hook up a script that cooks up wl1251-nvs.bin (caldata,
> > > macaddr) and then insmod the actual wl1251.ko module. Or you can
> > > just cook up the nvs on first device boot and store it in
> > > /lib/firmware (possibly overwriting the "generic" wl1251 from
> > > linux-firmware).
> >=20
> > This is what I would like to prevent -- overwriting (possible
> > readonly) system files with some device specific. It is really bad
> > idea!
>=20
> Agreed.
>=20
> "ifconfig hw ether XX" normally sets the address. I guess that's
> ioctl?

This sets temporary address and it is ioctl. IIRC same as what ethtool=20
uses. (ifconfig is already deprecated).

> And I guess we should use similar mechanism for permanent
> address.

I'm not sure here... Above ioctl =E2=86=91=E2=86=91=E2=86=91 is for changin=
g temporary mac=20
address. But here we do not want to change permanent mac address. We=20
want to tell kernel driver current permanent mac address which is stored=20
in permanent mac address storage (in N900 case in mtd). Just like=20
userspace helper as kernel driver do not have code which can read=20
permanent mac address.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart1899648.o0QrnXPIW8
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlg2Gr8ACgkQi/DJPQPkQ1Lw+gCfYwK6iix0CZcSwcpJ/7HdXVGb
qyMAnAnJehbMk6Td3DxVcyWOA0CNV67q
=sPWc
-----END PGP SIGNATURE-----

--nextPart1899648.o0QrnXPIW8--

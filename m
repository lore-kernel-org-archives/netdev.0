From: Alex Samad <alex@samad.com.au>
Subject: Re: Page swap allocation failure 2.6.25
Date: Mon, 14 Jul 2008 11:57:31 +1000
Message-ID: <20080714015731.GA26547@samad.com.au>
References: <20080713093047.GB661@samad.com.au> <20080713110222.GA16817@electric-eye.fr.zoreil.com> <20080713114944.GA3841@samad.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SUOF0GtieIMvvwua"
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>,
	linux-kernel@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755473AbYGNB55@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080713114944.GA3841@samad.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jul 13, 2008 at 09:49:44PM +1000, Alex Samad wrote:
> On Sun, Jul 13, 2008 at 01:02:22PM +0200, Francois Romieu wrote:
> > Alex Samad <alex@samad.com.au> :
> > [...]
> > > For a while now I have been receiving page swap allocation failures
> > >=20
> > >=20
> > > Similar to http://lkml.org/lkml/2008/6/10/3 and
> >=20
> > Order 0 failure. Your is an order 2 one.
> >=20
> > > http://lkml.org/lkml/2008/2/19/298
> >=20
> > Order 3 failure which was fixed with the e1000e driver.
>=20
>=20
> not sure about these, I will take your word for it.
>=20
> >=20
> > > and I have filed a bug with debian (Bug#486300)
> > >=20
> > >=20
> > > It seems like any time I put the system under load, transferring large
> > > files across the network  (1G nic, a r8186 and forcedeth and a
> > > broadcom).  I keep getting these errors
> >=20
> > May I assume that you are working with a MTU greater than 1500 bytes on
> > each interface ? If so plese add netdev@vger.kernel.org to the Cc: and
> > remove linux-kernel@ from the Cc:.
>=20
> I have 3 boxes, 2 are setup with > 1500 mtu and 1 isn't (the one with
> the r8186 driver), I have tested with >1500 mtu and with mtu =3D 1500 with
> the same result.
>=20
> >=20
> > [...]
> > > Jul 13 13:28:30 nas kernel: [  648.120756]  [<ffffffff881b525f>]
> > > :r8168:rtl8168_rx_fill+0x64/0x106
> >=20
> > It looks more like Realtek's out-of-tree driver than like the in-kernel
> > one. Is it a customised kernel ?
> The kernel is a stock debian amd64 kernel, not customised by me.
>=20
> I did build the r8168 from the realtek site.
>=20
> bit more info on the setup
>=20
> I have 2 laptops (both HP's), 1(A) running Vista 1(B) running Debian lenn=
y/sid
> (2.6.25). I have three servers 2 shuttles (forcedeth) (multimedia & hufpu=
f ) 1 gigabyte
> (realtek) (nas).
>=20
> The nas box is the one I coped the error from the syslog. it is
> primarily a nfs nas.  Hufpuf is the samba box, it used to be the nas
> box. it currently mounts a few (large) shares from nas.  Multimedia is a
> backup server.
>=20
> A & B & NAS have 1500 MTU
>=20
> multimedia and hufpuf can run with 9100 mtu
>=20
> I have tried
> i) coping files from A to hufpuf (smb) which then sends it on to nas via
> nfs
> ii) copy files from B to nas (nfs)
> iii) scp from B to hufpuf and then on to nas via nfs
> iv) scp from B to nas
> v) scp from hufpuf to nas
> vi) scp from hufpuf to multimedia
> vii) scp from multimedia to nas
> viii) hufpuf nfs to nas
> ix) multimedia nfs to nas
>=20
> all of these have caused these errors.
>=20
> when I was testing again today, I noticed when I was coping from A to
> hufpuf and then onto nas. that smaller files say < 200M would go okay,
> anything greater (or if the total of the files was greater) then I would
> start to get the errors.
> =20

I have done some more testing, I found that I had this line in my
sysctl.conf ( a hand over from a long ago)

net.ipv4.tcp_rmem =3D 4096        87380   2097152

this was in my 2 servers multimedia and hufpuf (forcedeth), I have
removed these and gone back to defaults.

Running a quick test scp'ing from the nas box to multimedia and to
hufpuf, doesn't cause any page faults, but scp to the nas box causes
more page faults. I tried scping between multimedia and hufpuf with
jumbo frames and that went all okay.

So it looks like it might be the 8186 drivers, that being the case I
will cc netdev@vger.kernel.org. I will leave linux-kernel still here for
a trial

thanks



>=20
> >=20
> > [...]
> > > Help
> >=20
> > Don't panic.
> not panicing yet but I am a bit concerned. the data seems to be okay
> even after these errors

thanks

>=20
>=20
> >=20
> > --=20
> > Ueimor
> >=20
>=20
> --=20
> "You see, the Senate wants to take away some of the powers of the adminis=
trative branch."
>=20
> 	- George W. Bush
> 09/19/2002
> Washington, DC



--=20
"See, free nations are peaceful nations. Free nations don't attack each oth=
er. Free nations don't develop weapons of mass destruction. "

	- George W. Bush
10/03/2003
Milwaukee, WI

--SUOF0GtieIMvvwua
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkh6sosACgkQkZz88chpJ2ObRQCdHxTHEUVadA4tZjb2dYeXDdyI
52wAoJru0wAoLgb1AQDtlYNw5HFTHGLh
=cOhE
-----END PGP SIGNATURE-----

--SUOF0GtieIMvvwua--

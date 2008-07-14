From: Alex Samad <alex@samad.com.au>
Subject: Re: [alex@samad.com.au: Re: Page swap allocation failure 2.6.25]
Date: Mon, 14 Jul 2008 17:27:41 +1000
Message-ID: <20080714072741.GA12747@samad.com.au>
References: <20080714035606.GA29227@samad.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="liOOAslEiF7prFVr"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail11.tpgi.com.au ([203.12.160.161]:49112 "EHLO
	mail11.tpgi.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754142AbYGNH1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 03:27:46 -0400
Received: from sydrt01.samad.com.au (adsl.samad.com.au [60.241.248.86])
	by mail11.tpgi.com.au (envelope-from alex@samad.com.au) (8.14.3/8.14.3) with ESMTP id m6E7RfBG029639
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 17:27:44 +1000
Received: from alex by smtp.samad.com.au with local  (Exim 4.69 #1 (Debian))
	id 1KIITF-0003KF-3E
	for <netdev@vger.kernel.org>; Mon, 14 Jul 2008 17:27:41 +1000
Content-Disposition: inline
In-Reply-To: <20080714035606.GA29227@samad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi


Sorry if I am breaking any rules by replying to my email, from my sent
items, I haven't received my copy from the list yet !?


I think I have tracked down the problem. the key word in the original
reply was about mtu.

So changed the sysctl values back to default, fixed up 2 box - the ones
with forcedeth driver.

I went over the nas box with a fine tooth comb. and what I found was
that i was setting up for jumbo frames, but because I have a mixed
environment some machine can accept large frames some can't I have a
scrip that sets individual mtu for machines.  anyway.

the mtu for the nic was being set to 6144 (the driver had limited it,
the original request was for 9100). but the routes where still in the
routing table with 9100 mtu, since fixing that up I don't seem to be
having the problem. I could reproduce the problem by scp 2G file between
the boxes, I have done that 5 times now with no crash.

If any one wants to follow that up please email directly as I will un
subscribe from the list now=20

Alex

On Mon, Jul 14, 2008 at 01:56:06PM +1000, Alex Samad wrote:
> Hi
>=20
> I am forwarding this again to the netdev mailing list, seems like my
> original mail did not make it to the list (checked www archive).
>=20
> Alex
> ----- Forwarded message from Alex Samad <alex@samad.com.au> -----
>=20
> From: Alex Samad <alex@samad.com.au>
> To: Francois Romieu <romieu@fr.zoreil.com>, linux-kernel@vger.kernel.org,
> 	Edward Hsu <edward_hsu@realtek.com.tw>
> Cc: netdev@vger.kernel.org
> Subject: Re: Page swap allocation failure 2.6.25
> Mail-Followup-To: Francois Romieu <romieu@fr.zoreil.com>,
> 	linux-kernel@vger.kernel.org,
> 	Edward Hsu <edward_hsu@realtek.com.tw>, netdev@vger.kernel.org
> List-ID: <linux-kernel.vger.kernel.org>
>=20
> On Sun, Jul 13, 2008 at 09:49:44PM +1000, Alex Samad wrote:
> > On Sun, Jul 13, 2008 at 01:02:22PM +0200, Francois Romieu wrote:
> > > Alex Samad <alex@samad.com.au> :
> > > [...]
> > > > For a while now I have been receiving page swap allocation failures
> > > >=20
> > > >=20
> > > > Similar to http://lkml.org/lkml/2008/6/10/3 and
> > >=20
> > > Order 0 failure. Your is an order 2 one.
> > >=20
> > > > http://lkml.org/lkml/2008/2/19/298
> > >=20
> > > Order 3 failure which was fixed with the e1000e driver.
> >=20
> >=20
> > not sure about these, I will take your word for it.
> >=20
> > >=20
> > > > and I have filed a bug with debian (Bug#486300)
> > > >=20
> > > >=20
> > > > It seems like any time I put the system under load, transferring la=
rge
> > > > files across the network  (1G nic, a r8186 and forcedeth and a
> > > > broadcom).  I keep getting these errors
> > >=20
> > > May I assume that you are working with a MTU greater than 1500 bytes =
on
> > > each interface ? If so plese add netdev@vger.kernel.org to the Cc: and
> > > remove linux-kernel@ from the Cc:.
> >=20
> > I have 3 boxes, 2 are setup with > 1500 mtu and 1 isn't (the one with
> > the r8186 driver), I have tested with >1500 mtu and with mtu =3D 1500 w=
ith
> > the same result.
> >=20
> > >=20
> > > [...]
> > > > Jul 13 13:28:30 nas kernel: [  648.120756]  [<ffffffff881b525f>]
> > > > :r8168:rtl8168_rx_fill+0x64/0x106
> > >=20
> > > It looks more like Realtek's out-of-tree driver than like the in-kern=
el
> > > one. Is it a customised kernel ?
> > The kernel is a stock debian amd64 kernel, not customised by me.
> >=20
> > I did build the r8168 from the realtek site.
> >=20
> > bit more info on the setup
> >=20
> > I have 2 laptops (both HP's), 1(A) running Vista 1(B) running Debian le=
nny/sid
> > (2.6.25). I have three servers 2 shuttles (forcedeth) (multimedia & huf=
puf ) 1 gigabyte
> > (realtek) (nas).
> >=20
> > The nas box is the one I coped the error from the syslog. it is
> > primarily a nfs nas.  Hufpuf is the samba box, it used to be the nas
> > box. it currently mounts a few (large) shares from nas.  Multimedia is a
> > backup server.
> >=20
> > A & B & NAS have 1500 MTU
> >=20
> > multimedia and hufpuf can run with 9100 mtu
> >=20
> > I have tried
> > i) coping files from A to hufpuf (smb) which then sends it on to nas via
> > nfs
> > ii) copy files from B to nas (nfs)
> > iii) scp from B to hufpuf and then on to nas via nfs
> > iv) scp from B to nas
> > v) scp from hufpuf to nas
> > vi) scp from hufpuf to multimedia
> > vii) scp from multimedia to nas
> > viii) hufpuf nfs to nas
> > ix) multimedia nfs to nas
> >=20
> > all of these have caused these errors.
> >=20
> > when I was testing again today, I noticed when I was coping from A to
> > hufpuf and then onto nas. that smaller files say < 200M would go okay,
> > anything greater (or if the total of the files was greater) then I would
> > start to get the errors.
> > =20
>=20
> I have done some more testing, I found that I had this line in my
> sysctl.conf ( a hand over from a long ago)
>=20
> net.ipv4.tcp_rmem =3D 4096        87380   2097152
>=20
> this was in my 2 servers multimedia and hufpuf (forcedeth), I have
> removed these and gone back to defaults.
>=20
> Running a quick test scp'ing from the nas box to multimedia and to
> hufpuf, doesn't cause any page faults, but scp to the nas box causes
> more page faults. I tried scping between multimedia and hufpuf with
> jumbo frames and that went all okay.
>=20
> So it looks like it might be the 8186 drivers, that being the case I
> will cc netdev@vger.kernel.org. I will leave linux-kernel still here for
> a trial
>=20
> thanks
>=20
>=20
>=20
> >=20
> > >=20
> > > [...]
> > > > Help
> > >=20
> > > Don't panic.
> > not panicing yet but I am a bit concerned. the data seems to be okay
> > even after these errors
>=20
> thanks
>=20
> >=20
> >=20
> > >=20
> > > --=20
> > > Ueimor
> > >=20
> >=20
> > --=20
> > "You see, the Senate wants to take away some of the powers of the admin=
istrative branch."
> >=20
> > 	- George W. Bush
> > 09/19/2002
> > Washington, DC
>=20
>=20
>=20
> --=20
> "See, free nations are peaceful nations. Free nations don't attack each o=
ther. Free nations don't develop weapons of mass destruction. "
>=20
> 	- George W. Bush
> 10/03/2003
> Milwaukee, WI
>=20
>=20
>=20
> ----- End forwarded message -----
>=20
> --=20
> "Border relations between Canada and Mexico have never been better."
>=20
> 	- George W. Bush
> 09/24/2001
> in a press conference with Canadian Prime Minister Jean Chretien



--=20
<Culus> there is 150 meg in the /tmp dir! DEAR LORD

--liOOAslEiF7prFVr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkh6/+oACgkQkZz88chpJ2N+oACgjnvgYPo7s9DJwmqoIZO5+Vqo
R9sAn1JTVo2zICWNBOqJDRp32sECCaMO
=QT1P
-----END PGP SIGNATURE-----

--liOOAslEiF7prFVr--

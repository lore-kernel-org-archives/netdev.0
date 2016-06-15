From: Henrik Austad <henrik@austad.us>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Wed, 15 Jun 2016 09:50:02 +0200
Message-ID: <20160615075002.GA5070@sisyphus.home.austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
 <20160613130059.GA20320@sisyphus.home.austad.us>
 <20160613193208.GA2441@netboy>
 <20160614093000.GB21689@sisyphus.home.austad.us>
 <20160614182615.GA2741@netboy>
 <20160614203810.GC21689@sisyphus.home.austad.us>
 <20160615070441.GB2919@netboy>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1yeeQ81UyVL57Vl7"
Cc: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
	alsa-devel@vger.kernel.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@linaro.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160615070441.GB2919@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 15, 2016 at 09:04:41AM +0200, Richard Cochran wrote:
> On Tue, Jun 14, 2016 at 10:38:10PM +0200, Henrik Austad wrote:
> > Whereas I want to do=20
> >=20
> > aplay some_song.wav
>=20
> Can you please explain how your patches accomplish this?

In short:

modprobe tsn
modprobe avb_alsa
mkdir /sys/kernel/config/eth0/link
cd /sys/kernel/config/eth0/link
<set approriate values vor the attributes>
echo alsa > enabled
aplay -Ddefault:CARD=3Davb some_song.wav

Likewise on the receiver side, except add 'Listener' to end_station=20
attribute

arecord -c2 -r48000 -f S16_LE -Ddefault:CARD=3Davb > some_recording.wav

I've not had time to fully fix the hw-aprams for alsa, so some manual=20
tweaking of arecord is required.


Again, this is a very early attempt to get something useful done with TSN,=
=20
I know there are rough edges, I know buffer handling and timestamping is=20
not finished


Note: if you don't have an intel-card, load tsn in debug-mode and it will=
=20
let you use all NICs present.

modprobe tsn in_debug=3D1


--=20
Henrik Austad

--1yeeQ81UyVL57Vl7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAldhCKoACgkQ6k5VT6v45lnc4wCg7wLZZ78MxAxAXdqu6/zGnc4D
fNUAoMfGnsIS2IozggU2+r7ulJBSBCDm
=MBnt
-----END PGP SIGNATURE-----

--1yeeQ81UyVL57Vl7--

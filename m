From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH v2 15/16] wl1251: Add sysfs file address for setting permanent mac address
Date: Tue, 10 Dec 2013 20:31:23 +0100
Message-ID: <201312102031.23797@pali>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com> <201312101852.17030@pali> <1386703339.30202.19.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2284039.d878SBvJzH";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@adurom.com>, Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386703339.30202.19.camel@dcbw.foobar.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2284039.d878SBvJzH
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Tuesday 10 December 2013 20:22:19 Dan Williams wrote:
> On Tue, 2013-12-10 at 18:52 +0100, Pali Roh=C3=A1r wrote:
> > On Tuesday 10 December 2013 18:49:22 Dan Williams wrote:
> > > On Tue, 2013-12-10 at 18:14 +0100, Pali Roh=C3=A1r wrote:
> > > > On Tuesday 10 December 2013 17:10:50 Pali Roh=C3=A1r wrote:
> > > > > On Tuesday 10 December 2013 16:49:23 Kalle Valo wrote:
> > > > > > Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:
> > > > > > > Driver wl1251 generating mac address randomly at
> > > > > > > startup and there is no way to set permanent mac
> > > > > > > address via SET_IEEE80211_PERM_ADDR. This patch
> > > > > > > export sysfs file which can set permanent mac
> > > > > > > address by userspace helper program. Patch is
> > > > > > > needed for devices which do not store mac address
> > > > > > > in internal wl1251 eeprom.
> > > > > > >=20
> > > > > > > Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
> > > > > >=20
> > > > > > We have ioctl() command for setting the mac address.
> > > > >=20
> > > > > Really? Is there ioctl for setting permanent mac
> > > > > address? Can you show me it?
> > > >=20
> > > > Now I looked at it again and I did not found any ioctl
> > > > for it. There is only ioctl cmd for getting address,
> > > > not setting it.
> > > >=20
> > > > #define SIOCETHTOOL 0x8946
> > > >=20
> > > > /* Get permanent hardware address */
> > > > #define ETHTOOL_GPERMADDR 0x00000020
> > >=20
> > > Yeah, because it's supposed to be permanent and
> > > unchanging. Which means if there was an ioctl for it,
> > > that would be contrary to the purpose of a permanent MAC
> > > address.
> > >=20
> > > I realize the N900 stores the WiFi MAC address completely
> > > differently than many other systems, and that's why this
> > > sysfs file was created.  I don't really have a great
> > > converged solution for that, other than what you've
> > > currently got, or perhaps adding SPERMADDR to ethtool.=20
> > > One thing I *would* like though, is a restriction on the
> > > sysfs file such that if the permanent MAC is already set,
> > > it cannot be set again.  Otherwise the permanent MAC
> > > address isn't permanent at all.
> > >=20
> > > Dan
> >=20
> > Maybe another way could be to use request_firmware to load
> > address from userspace... Or what do you think?
>=20
> That sounds like a great idea to try.  A number of devices
> either need stub firmware to read the MAC from EEPROM, or do
> use request_firmware() to load firmware before they read the
> MAC.  You may have to use request_firmware() synchronously
> though to ensure that the MAC is read before registering with
> mac80211.
>=20
> Dan

So, if you like this idea, can you help me how to write udev rule=20
which will run my own program (it print mac address) and send mac=20
address when driver ask for mac address in request_firmware?=20
Problem is that default udev rule for firmware trying to load data=20
from /lib/firmware/... but in this case mac address first must be=20
read from special location and converted to correct format.

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart2284039.d878SBvJzH
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlKnbAsACgkQi/DJPQPkQ1KMAwCfZsn5s3EjIltZnqxjpd4lo+9v
CQEAn1wBPRMrVsWALaU9ItBeBSaB6Iki
=vT15
-----END PGP SIGNATURE-----

--nextPart2284039.d878SBvJzH--

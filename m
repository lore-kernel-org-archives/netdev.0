From: Alban Bedel <alban.bedel@avionic-design.de>
Subject: Re: [PATCH] usbnet: ax88179_178a: Add support for writing the
 EEPROM
Date: Thu, 25 Aug 2016 12:07:33 +0200
Message-ID: <20160825120733.3413d395@avionic-0020>
References: <20160824135231.21782-1-alban.bedel@avionic-design.de>
        <1472049039.11480.10.camel@suse.com>
        <20160824164058.6ec64a8e@avionic-0020>
        <1472116596.2877.23.camel@suse.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/VOX7tV8LVkxI7rzzMo9rA3u"; protocol="application/pgp-signature"
Cc: Alban Bedel <alban.bedel@avionic-design.de>,
        Freddy Xin <freddy@asix.com.tw>, linux-kernel@vger.kernel.org,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472116596.2877.23.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/VOX7tV8LVkxI7rzzMo9rA3u
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 25 Aug 2016 11:16:36 +0200
Oliver Neukum <oneukum@suse.com> wrote:

> On Wed, 2016-08-24 at 16:40 +0200, Alban Bedel wrote:
> > On Wed, 24 Aug 2016 16:30:39 +0200
> > Oliver Neukum <oneukum@suse.com> wrote:
> >  =20
> > > On Wed, 2016-08-24 at 15:52 +0200, Alban Bedel wrote: =20
>=20
> > > > +       if (block !=3D data)
> > > > +               kfree(block);   =20
> > >=20
> > > And if block =3D=3D dta, what frees the memory? =20
> >=20
> > In this case this function didn't allocate any memory, so there is
> > nothing to free. =20
>=20
> Hi,
>=20
> I see. kfree() has a check for NULL, so you could drop the
> test, but it doesn't matter much either way.

I think you misunderstand something here. data is the buffer passed
by the caller and block is a local variable. There is two cases:

1) The data to write is block aligned, then we use the caller buffer
   as is and set block =3D data.
2) The requested data is not block aligned, then we kalloc block.

In both case the writing loop then use the block pointer. Afterwards
we only need to kfree block in case 2, that is when block !=3D data.

Alban

--Sig_/VOX7tV8LVkxI7rzzMo9rA3u
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXvsNlAAoJEHSUmkuduC28j9UP/0SeN9+zKBIg1EF6877ISXu5
8k/BIABcqbR7dvv2eQchDrgm61WKDO6db4zxao8/qPCWTteMA6XX8tORicFzWnEG
TTBavQd2mKQ5pKgh9LPC45xHS0HFrL6mL+yb2xg3lr74tEekjmebpN+gUwkQKt5G
5eAyKsnLNtgqZhJjkSNo4PocK64++6WLSpH8s6nH1aGwgklBI1TnTmEtttNfXNe8
9ERUTnX5Fx5E/avBpJC23gnP9t9onFju+3U60ecwwPlhdqjb9+dBTHgY7Sv6D5q2
5DmxD1zEFWpEF98oInPJst9S1v4vy8MRxD0IMuV81GeBdFnwFwnXLDCmneDLEdwy
GKiAOOplA9gQTmMOsknbJ78jv1JEhSE8OwlAqXOzvK99FuMQ/Rzjrp1+PeOtFcPs
l1L18uMprX/ouje7aLuTGD+crTtGtzWqnLZCzIAdww/ko1jA/sY8TuXAvcqQuOI7
zb2Wp1e7qCHusU9cTwIZNlJtumW9tzD6T/qHVol7m7/IoIHWRcFJ4vpP5BpWXK79
oDO7URjclJCbtXK3nJefMCELV9fkxuH8FtOs5BtBI0MqtOqSpz9E5EtB5g0R3P9K
bFGk8zGK5fVExJ4bLqEqCad14hvj+/m4ltu6bt8sM1MZQD7aDLoVNjoqqQwfA5DY
/wv3xJiYoiXAB+sg7Xh4
=ozwp
-----END PGP SIGNATURE-----

--Sig_/VOX7tV8LVkxI7rzzMo9rA3u--

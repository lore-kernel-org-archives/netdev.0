From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] stmmac: disable tx coalescing
Date: Sun, 11 Dec 2016 20:57:48 +0100
Message-ID: <20161211195748.GA20574@amd>
References: <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161205122711.GA30774@amd>
 <20161211190750.GA14287@amd>
 <20161211.143113.268450274785467682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="/9DWx/yDrRhgMJTb"
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.torgue@st.com,
        LinoSanfilippo@gmx.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161211.143113.268450274785467682.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun 2016-12-11 14:31:13, David Miller wrote:
> From: Pavel Machek <pavel@ucw.cz>
> Date: Sun, 11 Dec 2016 20:07:50 +0100
>=20
> > David, ping? Can I get you to apply this one?
> >=20
> > As you noticed, tx coalescing is completely broken in that driver, and
> > not easy to repair. This is simplest way to disable it. It can still
> > be re-enabled from userspace, so code can be fixed in future.
>=20
> Sorry I'm not applying this, I want you and the driver maintainer
> to reach a real solution.

This is what you said about this driver:

# > 4.9-rc6 still has the delays. With the
# >
# > #define STMMAC_COAL_TX_TIMER 1000
# > #define STMMAC_TX_MAX_FRAMES 2
# >
# > settings, delays go away, and driver still works. (It fails fairly
# > fast in 4.4). Good news. But the question still is: what is going on
# > there?
#=20
# 256 packets looks way too large for being a trigger for aborting the
# TX coalescing timer.
#=20
# Looking more deeply into this, the driver is using non-highres timers
# to implement the TX coalescing.  This simply cannot work.
#=20
# 1 HZ, which is the lowest granularity of non-highres timers in the
# kernel, is variable as well as already too large of a delay for
# effective TX coalescing.
#=20
# I seriously think that the TX coalescing support should be ripped out
# or disabled entirely until it is implemented properly in this driver.

I'm doing just that -- disabling it entirely until it is done
properly.

Unfortunately, maintainer does not think delays are huge problem. So I
need your help here.

Thanks,								=09
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--/9DWx/yDrRhgMJTb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlhNr7wACgkQMOfwapXb+vJ5oQCeNT0wbg1JqVW+aQqSs9Q4V2K6
rekAn0T/EnKOxWsA2MmNA+kEXIceiMZj
=QhkG
-----END PGP SIGNATURE-----

--/9DWx/yDrRhgMJTb--

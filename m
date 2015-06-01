From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/1] net: core: 'ethtool' issue with querying phy
 settings
Date: Mon, 01 Jun 2015 19:05:31 +0100
Message-ID: <1433181931.6319.176.camel@decadent.org.uk>
References: <1432157730-26865-2-git-send-email-aparames@broadcom.com>
	 <20150522.161511.1791346966770946099.davem@davemloft.net>
	 <1433102046.6319.103.camel@decadent.org.uk>
	 <20150531.171940.1635713770956335110.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lOp6ClkIurfkHa/dfQx3"
Cc: aparames@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com, rjui@broadcom.com,
	sbranden@broadcom.com, jdzheng@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150531.171940.1635713770956335110.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-lOp6ClkIurfkHa/dfQx3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-05-31 at 17:19 -0700, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Sun, 31 May 2015 20:54:06 +0100
>=20
> > On Fri, 2015-05-22 at 16:15 -0400, David Miller wrote:
> >> From: Arun Parameswaran <aparames@broadcom.com>
> >> Date: Wed, 20 May 2015 14:35:30 -0700
> >>=20
> >> > When trying to configure the settings for PHY1, using commands
> >> > like 'ethtool -s eth0 phyad 1 speed 100', the 'ethtool' seems to
> >> > modify other settings apart from the speed of the PHY1, in the
> >> > above case.
> >> >=20
> >> > The ethtool seems to query the settings for PHY0, and use this
> >> > as the base to apply the new settings to the PHY1. This is
> >> > causing the other settings of the PHY 1 to be wrongly
> >> > configured.
> >> >=20
> >> > The issue is caused by the '_ethtool_get_settings()' API, which
> >> > gets called because of the 'ETHTOOL_GSET' command, is clearing
> >> > the 'cmd' pointer (of type 'struct ethtool_cmd') by calling
> >> > memset. This clears all the parameters (if any) passed for the
> >> > 'ETHTOOL_GSET' cmd. So the driver's callback is always invoked
> >> > with 'cmd->phy_address' as '0'.
> >> >=20
> >> > The '_ethtool_get_settings()' is called from other files in the
> >> > 'net/core'. So the fix is applied to the 'ethtool_get_settings()'
> >> > which is only called in the context of the 'ethtool'.
> >> >=20
> >> > Signed-off-by: Arun Parameswaran <aparames@broadcom.com>
> >> > Reviewed-by: Ray Jui <rjui@broadcom.com>
> >> > Reviewed-by: Scott Branden <sbranden@broadcom.com>
> >>=20
> >> Applied and queued up for -stable, thanks.
> >=20
> > Please revert this.  This is an incompatible API change, not a bug fix.
> > The established semantics are that 'phyad' is filled in by the driver;
> > it is not a parameter to the ETHTOOL_GSET command.
>=20
> But then how in the world can the user specify specific PHY ADs for
> a device that will respond to more than one?

ETHTOOL_SSET sets the current PHY address and ETHTOOL_GSET gets it.

If multiple PHYs need to be configured for a single link then the driver
should configure them all at the same time rather than making it the
administrator's problem.

What we can't support with the current API are:
- multiple physical links behind a single net device (different
  configuration possible for each link)
- multiple PHYs are needed for a single link, and the driver can't
  automatically decide which to use (multiple addresses to set)

Ben.

--=20
Ben Hutchings
Power corrupts.  Absolute power is kind of neat.
                           - John Lehman, Secretary of the US Navy 1981-198=
7

--=-lOp6ClkIurfkHa/dfQx3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWye9ee/yOyVhhEJAQp1Tg/8DGJ8jJh45RbFnrMyW5i4XWpDbOCa+hcW
NuSBgN5R9pm5mp8Vl+jTsTMxlvWdJYdwXvYcsAzt/Uyaqp3yWuPU0QeaxiKsf26n
ScC2rTsF8G2MneWF80bc4MBaxiZMa6ocox5xSJbfzkASGMY32fDzYv9oGpjGmjX6
3tzU4yo3+vmnFpTmht6NONbpve0ucY43oYdtZMffkXJ/9j0EjTu1WZEMLGwLl413
YFORAaxJPiHQGbaqq2jR9OKnlfq9guZK7MgN+Rcj4h1zAwH58UWBlYJUppydkXER
wxif4X4yc+pCBEin2mGOjeSdckdiiO37A5NmVp6holLj0aui8PEYI2qUGIdFzGfE
MsFWXI+09VK2utM8VAS5HDuHLqnlZh9HdcM6kKGmuRYxrcPmqy794b9Aaj0c8GXH
oljGxxSjZgleFZWmuamZ6QV/zGfbFDWv0XczcMi++SuvC3W6ZLwVrFNdahIHXg42
1fBtFdPsK/0xh6g6Fje9obtJa5PtSHgoHbRPiBpNvhMLc9CfZr82E+uwybIOPC0t
udzn0QZ/gYSN2uqADNx6b0AfMFClJTFMaDM9cH72JnSIBkaw721qDXgWIl5dbQjH
YEtUCaTcXr7gp1Q2FFnB6YMez0pHHK5q9cpE8VreIorjY/YbSb9PiigrXIVtzvz3
+GCH9p9fRMQ=
=yDjf
-----END PGP SIGNATURE-----

--=-lOp6ClkIurfkHa/dfQx3--

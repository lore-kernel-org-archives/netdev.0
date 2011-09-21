From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH v2 1/3] net/fec: change phy-reset-gpio request warning
 to debug message
Date: Wed, 21 Sep 2011 14:11:59 +0200
Message-ID: <20110921121159.GG1966@pengutronix.de>
References: <1316603432-20032-1-git-send-email-shawn.guo@linaro.org>
 <1316603432-20032-2-git-send-email-shawn.guo@linaro.org>
 <20110921112555.GE1966@pengutronix.de>
 <20110921120341.GG28907@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BzCohdixPhurzSK4"
Cc: Shawn Guo <shawn.guo@linaro.org>,
	"David S. Miller" <davem@davemloft.net>, patches@linaro.org,
	netdev@vger.kernel.org,
	Troy Kisky <troy.kisky@boundarydevices.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	linux-arm-kernel@lists.infradead.org,
	Lothar =?iso-8859-15?Q?Wa=DFmann?= <LW@KARO-electronics.de>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56910 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778Ab1IUMMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 08:12:03 -0400
Content-Disposition: inline
In-Reply-To: <20110921120341.GG28907@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--BzCohdixPhurzSK4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 21, 2011 at 08:03:42PM +0800, Shawn Guo wrote:
> On Wed, Sep 21, 2011 at 01:25:55PM +0200, Wolfram Sang wrote:
> > Hi Shawn,
> >=20
> > On Wed, Sep 21, 2011 at 07:10:30PM +0800, Shawn Guo wrote:
> > > FEC can work without a phy reset on some platforms, which means not
> > > very platform necessarily have a phy-reset gpio encoded in device tre=
e.
> > > So it makes more sense to have the phy-reset-gpio request failure as
> > > a debug message rather than a warning.
> >=20
> > Or remove it entirely?
> >=20
> I would like to keep it.  When people want to debug at this point, they
> do not need to type the debug message.

I just think the message might be confusing in case you don't need the
gpio, because then failing is expected behaviour. For those platforms,
it is not even an error then, so you must drop returning the error. To
be very precise, you should check of_get_named_gpio() and return if no
gpio is specified. Then, you can distinguish that case from problems
when getting the GPIO.

> > I also wanted to suggested to drop returning the error code, since it is
> > not an error anymore, strictly speaking. Then I noticed that the caller
> > does not check the error code. So, this could be added or turn the
> > function to void?
> >=20
> To me, keep the return value as integer is more scalable.  Someday,
> someone need to add more stuff in the function, or want to improve
> the caller to check return value, it plays.

I agree that keeping it int is way better. But why not add it now to
keep things proper and tested? If this patch gets accepted as it is and
later someone else will add error checking to the caller, your platform
will lose FEC support as a regression.

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--BzCohdixPhurzSK4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk551I8ACgkQD27XaX1/VRshhQCeNPL9bUM4C1jYQrEPTWobHcZP
jUsAn3n4lQfpNzSIHnc0gn7/RhHn2Som
=gk5Q
-----END PGP SIGNATURE-----

--BzCohdixPhurzSK4--

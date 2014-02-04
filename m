From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] dp83640: Support a configurable number of periodic
 outputs
Date: Tue, 04 Feb 2014 10:53:58 +0000
Message-ID: <1391511238.3003.25.camel@deadeye.wl.decadent.org.uk>
References: <1391503942-694-1-git-send-email-stefan.sorensen@spectralink.com>
	 <20140204092939.GA9862@netboy>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Gaz+MVF+Q5e9U8ePgC4V"
Cc: Stefan =?ISO-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50562 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750937AbaBDKyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 05:54:02 -0500
In-Reply-To: <20140204092939.GA9862@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Gaz+MVF+Q5e9U8ePgC4V
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-02-04 at 10:29 +0100, Richard Cochran wrote:
> On Tue, Feb 04, 2014 at 09:52:22AM +0100, Stefan S=C3=B8rensen wrote:
> > The driver is currently limited to a single periodic output.
> > This patch makes the number of peridodic output dynamic by
> > dropping the gpio_tab module parameter and adding cal_gpio,
> > perout_gpio_tab and extts_gpio_tabs parameters.
>=20
> ...
>=20
> >  module_param(chosen_phy, int, 0444);
> > -module_param_array(gpio_tab, ushort, NULL, 0444);
> > +module_param(cal_gpio, int, 0444);
> > +module_param_array(perout_gpio_tab, int, &n_perout, 0444);
> > +module_param_array(extts_gpio_tab, int, &n_extts, 0444);
> > =20
> >  MODULE_PARM_DESC(chosen_phy, \
> >  	"The address of the PHY to use for the ancillary clock features");
> > -MODULE_PARM_DESC(gpio_tab, \
> > -	"Which GPIO line to use for which purpose: cal,perout,extts1,...,extt=
s6");
> > +MODULE_PARM_DESC(cal_gpio, "Which GPIO line to use for calibration");
> > +MODULE_PARM_DESC(perout_gpio_tab, "Which GPIO lines to use for periodi=
c output");
> > +MODULE_PARM_DESC(extts_gpio_tab, "Which GPIO lines to use for external=
 timestamping");
>=20
> Modules parameters are surely easiest (for the developer), but perhaps
> the time has come for the "right way."
>=20
> Currently there is no interface for configuring the GPIOs used by PHC
> devices, and last year I was going to add the GPIOs to the igb
> driver. The conclusion of the discussion was that module parameters
> are bad for this, but ethtool is good.
>=20
>   http://www.spinics.net/lists/netdev/msg237692.html
>=20
> [ I did not follow through to come up with an ethtool way of configuring
>   the igb pins. ]
>=20
> Even though it is more work, I think the way forward is to invent a
> way to let the user configure this kind of thing via ethtool. Would
> you care to take a stab at this?

It seems to me that this is board configuration, not user configuration,
so it should be defined in DT or ACPI or whatever.

Are there boards which expose multiple GPIOs for users to plug together
PPS signals?

Ben.

--=20
Ben Hutchings
One of the nice things about standards is that there are so many of them.

--=-Gaz+MVF+Q5e9U8ePgC4V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvDGxue/yOyVhhEJAQq82A/+LnukX1Vo7TZoE8Vrir34pdrapdOQtQ1C
D33+w6D25WF2whp1EzF+F+AlsMys4rByQwbJAf3TLqRf/WsQUElcK5heUqhg+bET
gLzSFae1F4arut6ynNiqueERdBqipeeElV3Dc/8tn7qyJWE6AnpqSKiRoM43hfgR
F7Itg0dIpJptvQBKzvhij2RZJ2h8NeEI20abhT9Q/djORgKB5bCSFLnDJhccYo3p
hnDioIvD95GZ2vzhNKB+A3gIq8dbCGmiL1g0NkHiQmabAp7fx8wv9deEES4mRsXP
20KoGIk1vLUMcM6IzNe1Pw4qdau2IR/4D8kbjoMV0qZ4KgnLojE6BLLgw5kFnJHo
Rs+46Qv3ESFIha0DEKTNypMLrgCZSq2ypX6eyYweQcvVmY0lWkI5gphANm0DebZi
/M5D2bRa9n1+43D0kDVjBy5MlfeKUD9PAgRuMKIw5IhNfud1IXY0DjtAEt+engB7
tvzt7t+i9mNcP81w9Aw6hepfvsu20SshlC+ZFSjt3+MsqJhrvCEdXQcEcfIqteTY
S4b/PXWh0nucCZC+0GbwjcvHqvQs3zKC+3lv0O/rW+gpysGngdvG1YWk/NrG85YP
dtsHcUOL+OooIQNFdso70IhgkyCxXY+5b/44k6O+sIKOtcAGNNGVGa6I5gYLb1nL
rUa/ZDiirWc=
=zG/a
-----END PGP SIGNATURE-----

--=-Gaz+MVF+Q5e9U8ePgC4V--

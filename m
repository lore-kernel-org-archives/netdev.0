From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/1] net: core: 'ethtool' issue with querying phy
 settings
Date: Sun, 31 May 2015 20:54:06 +0100
Message-ID: <1433102046.6319.103.camel@decadent.org.uk>
References: <1432157730-26865-1-git-send-email-aparames@broadcom.com>
	 <1432157730-26865-2-git-send-email-aparames@broadcom.com>
	 <20150522.161511.1791346966770946099.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hTwdsR8IgKm8vygbA0lB"
Cc: aparames@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com, rjui@broadcom.com,
	sbranden@broadcom.com, jdzheng@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58528 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751079AbbEaTyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 15:54:20 -0400
In-Reply-To: <20150522.161511.1791346966770946099.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hTwdsR8IgKm8vygbA0lB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-05-22 at 16:15 -0400, David Miller wrote:
> From: Arun Parameswaran <aparames@broadcom.com>
> Date: Wed, 20 May 2015 14:35:30 -0700
>=20
> > When trying to configure the settings for PHY1, using commands
> > like 'ethtool -s eth0 phyad 1 speed 100', the 'ethtool' seems to
> > modify other settings apart from the speed of the PHY1, in the
> > above case.
> >=20
> > The ethtool seems to query the settings for PHY0, and use this
> > as the base to apply the new settings to the PHY1. This is
> > causing the other settings of the PHY 1 to be wrongly
> > configured.
> >=20
> > The issue is caused by the '_ethtool_get_settings()' API, which
> > gets called because of the 'ETHTOOL_GSET' command, is clearing
> > the 'cmd' pointer (of type 'struct ethtool_cmd') by calling
> > memset. This clears all the parameters (if any) passed for the
> > 'ETHTOOL_GSET' cmd. So the driver's callback is always invoked
> > with 'cmd->phy_address' as '0'.
> >=20
> > The '_ethtool_get_settings()' is called from other files in the
> > 'net/core'. So the fix is applied to the 'ethtool_get_settings()'
> > which is only called in the context of the 'ethtool'.
> >=20
> > Signed-off-by: Arun Parameswaran <aparames@broadcom.com>
> > Reviewed-by: Ray Jui <rjui@broadcom.com>
> > Reviewed-by: Scott Branden <sbranden@broadcom.com>
>=20
> Applied and queued up for -stable, thanks.

Please revert this.  This is an incompatible API change, not a bug fix.
The established semantics are that 'phyad' is filled in by the driver;
it is not a parameter to the ETHTOOL_GSET command.

Ben.

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-hTwdsR8IgKm8vygbA0lB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWtm4+e/yOyVhhEJAQoBUxAAm+kbFmU3xfoJM8qf+GnLnwWpjgyPip0e
sL0Mzq9oyKSoHHfmKAErhgD/3ABsMRfU8JC0yc5N8R+uQdvXTPk+TpOXKVzPPqMj
o/kyv7giWA7LBWhhGsYHZd30jwOpdVi2hwSs0ulw0OrccdTym38lFI26FkQOt94Q
G9M69XS5ufwTnkhZs5EXjhqXkvwGxsNy5OiZ/mvcb2H59lsu6YeVgXwuI3lqqf4f
VyaXNn2G7xMA2ure0ayKFvWiTMpkmoTMXEczrtuSGDw1AomQ+Tyc2TpBZO4GZvZF
a7Gu4D+ONAUq638oF5xZjuHeH80/A8KwqK4KUFGF1qZojuknSOtSmCnjMd2ZiiSx
o4+IFVGpqPsZDV3YSFKlId9vtYt4F2VX/VWLzwiBCOwykRefQZGYpm28qv/C5IJI
ALPv3TQr1fqxEZscFHs8BUdJkRvaz3kmJhzJs6c22HLcI9Y+99YeneaPFPqpONbF
Y5cQCeBSOg7dcw0zjCs6zeranV/gPPAt0v8+2dfubguCyL1QGA7Wy9GufE49GW/Q
bx8lvXY32dzgXVeHtvmIE/rHH9Hn/ocOPL5WKtjyChqIStyRhfpcHep+KpVK5bVC
K6w9YgelvWagvDetPCihS8cNhtWsqjAHD10bzKPRbwnXDD1/kX7j5vAhu7QXiKyH
62Osg4CjQ7c=
=/LlU
-----END PGP SIGNATURE-----

--=-hTwdsR8IgKm8vygbA0lB--

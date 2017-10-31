From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v10 0/8] net: stmmac: dwmac-sun8i: Handle integrated PHY
Date: Tue, 31 Oct 2017 14:33:15 +0100
Message-ID: <20171031133315.qe74frvm6gt3qsta@flea>
References: <20171031081915.18960-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="7nphdao5ujy2cfmt"
Cc: robh+dt@kernel.org, mark.rutland@arm.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:55883 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751620AbdJaNdS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 09:33:18 -0400
Content-Disposition: inline
In-Reply-To: <20171031081915.18960-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--7nphdao5ujy2cfmt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 31, 2017 at 09:19:07AM +0100, Corentin Labbe wrote:
> Hello
>=20
> The current way to find if the PHY is internal is to compare DT phy-mode
> and emac_variant/internal_phy.
> But it will negate a possible future SoC where an external PHY use the
> same phy mode than the integrated one.
>=20
> This patchs series adds a new way to handle this problem via a mdio-mux.
>=20
> The first try was to create a new MDIO mux "mdio-mux-syscon".
> mdio-mux-syscon working the same way than mdio-mux-mmioreg with the excep=
tion
> that the register is used via syscon/regmap.
> But this solution does not work for two reason:
> - changing the MDIO selection need the reset of MAC which cannot be done =
by the
>         mdio-mux-syscon driver
> - There were driver loading order problem:
>         - mdio-mux-syscon needing that stmmac register the parent MDIO
>         - stmmac needing that child MDIO was registered just after regist=
ering parent MDIO
>=20
> So we cannot use any external MDIO-mux.
>=20
> The final solution was to represent the mdio-mux in MAC node and let
> the MAC handle all things.
>=20
> Since DT bits was reverted in 4.13, this patch series include the
> revert of the revert.
>=20
> I have let patch splited for easy review. (for seeing what's new)
> But the final serie could have some patch squashed if someone want.
> Like squashing patch and 1 and 2 (documentation)

Applied the patches, and I'll send a PR for it tomorrow after one
linux-next run.

Hopefully it will be merged in time for 4.15.

Thanks for your persistence,
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--7nphdao5ujy2cfmt
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZ+HubAAoJEBx+YmzsjxAgUc0QAIbok/mbS8ZICo1Bpo7IIyOA
y9m6awFmhhKP/OVDLI/uuV+QREoj/z999LU36ybzRxJ1oDd6Yn6J6cl27WHEcOiM
hOzg6hk/xpch+NwBmzszp01Mc9RKDeq59cG44QmDPZZpLq352vaXZukJA5jEhXOI
8Lw9aQe0FV6HZDvbgRXsbTPnpyw+943HOhrsWUI2i5pZYgonfkRsYrY3xF6fy2bV
edJIXJb+lpGKHrA+DZ4NHm3EcOoHvcw1VyDLEpi6pMwSPQrRaf+ltSZ0z11D5ev0
Iwp7LlqqEuJF1dV5XhuAiJM0US85f31y2E/DB2ueCeort3713B4JC3Li+0dQSLbv
hUce1Qvp0qy9kYluanUBk0SrZ1OVyxFxsTp3yIhV8+LBHaLxCFg682jJiS1GkI62
oNt1WXTk/zgCPtPKqCLNPfWBImlvZgnzDmkYF50/Xg81bcVGiF98Ja8A9pG4EKqO
Ho2Wz7NieqsbaEhZ/7i8rm+t/pCQtjeBWZ91TlvCj57HKl21GqIXK0AUbnanZEIS
NbIPDx/3jF0GQ/M6vHy/xpYlJDTYY4vC2knNJOGaYt/w6sQ/zG7Npm8brzKjQVFZ
wL6MxczyR4MTt71OQaOrU1ECocNCNy+uFTzZrQG/d4V6EPCjAUd+xx1IPgeoFT6g
NJCv7U1l2JZbedzbBOpq
=qgcT
-----END PGP SIGNATURE-----

--7nphdao5ujy2cfmt--

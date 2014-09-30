From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT
 mechanism
Date: Tue, 30 Sep 2014 15:26:50 +0200
Message-ID: <20140930132650.GN1325@katana>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com>
 <1410273070-22485-3-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MSd2ShuMixI0uVaZ"
Cc: wg@grandegger.com, mkl@pengutronix.de, tony@atomide.com,
	tglx@linutronix.de, mugunthanvnm@ti.com, george.cherian@ti.com,
	balbi@ti.com, nsekhar@ti.com, nm@ti.com,
	sergei.shtylyov@cogentembedded.com, linux-omap@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sauhun.de ([89.238.76.85]:39702 "EHLO pokefinder.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752043AbaI3N0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 09:26:23 -0400
Content-Disposition: inline
In-Reply-To: <1410273070-22485-3-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MSd2ShuMixI0uVaZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 09, 2014 at 05:31:09PM +0300, Roger Quadros wrote:
> Some TI SoCs like DRA7 have a RAMINIT register specification
> different from the other AMxx SoCs and as expected by the
> existing driver.
>=20
> To add more insanity, this register is shared with other
> IPs like DSS, PCIe and PWM.
>=20
> Provides a more generic mechanism to specify the RAMINIT
> register location and START/DONE bit position and use the
> syscon/regmap framework to access the register.
>=20
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> ---
>  .../devicetree/bindings/net/can/c_can.txt          |   7 ++
>  drivers/net/can/c_can/c_can.h                      |  11 ++-
>  drivers/net/can/c_can/c_can_platform.c             | 109 +++++++++++++++=
------
>  3 files changed, 95 insertions(+), 32 deletions(-)
>=20
> diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Docume=
ntation/devicetree/bindings/net/can/c_can.txt
> index 8f1ae81..e12d1a1 100644
> --- a/Documentation/devicetree/bindings/net/can/c_can.txt
> +++ b/Documentation/devicetree/bindings/net/can/c_can.txt
> @@ -13,6 +13,13 @@ Optional properties:
>  - ti,hwmods		: Must be "d_can<n>" or "c_can<n>", n being the
>  			  instance number
> =20
> +- ti,raminit-syscon	: Handle to system control region that contains the
> +			  RAMINIT register. If specified, the second memory resource
> +			  in the reg property must index into the RAMINIT
> +			  register within the syscon region

There seems to be a simple "syscon" property these days.

> +- ti,raminit-start-bit	: Bit posistion of START bit in the RAMINIT regis=
ter
> +- ti,raminit-done-bit	: Bit position of DONE bit in the RAMINIT register

This should not be encoded in DT! This is not describing hardware setup.
The driver should know where the bits are for the syscon phandle,
depending on which SoC it runs...


--MSd2ShuMixI0uVaZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUKq+aAAoJEBQN5MwUoCm2Z8wQALPPz95yERSUjhtUDdml2L+F
U+xVf79JznwSj9mfF8VXrBVKfF48SLtsUipzBftBMb+QdX9rsUrWECDFm3TNOm9A
bdIJZ29I2zqRtZKPCa8CSTzE5AZTrzqRkU+fnjo+GKsR5kGQgESLPjYI9twevtOh
D6ZLyZt7YpvK8f9CIRtBMbws19ZwA5/x0Z+y1nDJOqqGR4VrchGMBFcP4Gr3lo1g
yJifRXLGDB20vu9hw/EcPp3DC3UOlLAp2lrSmJwsyhAD6OX2v/DacKdc0bVZZxUs
6oFHydiHV+4xMb3tgVS6L8HoSBrU9FjJd58qjtMboeY0XHphgghSOHDIl93NxKAW
o5CN5KuSCtQW0QT5z7Bj5TVfjixp+TgYzUXqyrs0l3dTL0BiDOswq0Y8kIax6nXo
4dN0BuBR3mHpSr84I/o8sGQXnc44bJivljUKd4c6THmw84FssRlDw1JW6CuEv5Rn
xPHtD+sSRc9wzI0hY3tkYXNmbMDqWWZ7lSzqRWWQUtoXm/ddlt/0QGWhSjs8rSmC
xspg8r+Pa3fLqejXhs3nPRos2g1Vi15iYs5u1tjncKvT/T4tXn3JOFXyZxKr+dIP
jwrbM74uKdW+BTxq0e29jyhi98/0tSNGej2kXDQ3rfF4M1buoOuUHrU+quZbvfjV
n4lsXntTguEFsQAvWpqN
=cEVJ
-----END PGP SIGNATURE-----

--MSd2ShuMixI0uVaZ--

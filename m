From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Tue, 30 Sep 2014 15:45:36 +0200
Message-ID: <542AB400.6080608@pengutronix.de>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com> <1410273070-22485-3-git-send-email-rogerq@ti.com> <20140930132650.GN1325@katana>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Ab7sQouDq6F8vFcT7sgAUeKgFrE6VSXUv"
Cc: wg@grandegger.com, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Wolfram Sang <wsa@the-dreams.de>, Roger Quadros <rogerq@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43002 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbaI3NtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 09:49:11 -0400
In-Reply-To: <20140930132650.GN1325@katana>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Ab7sQouDq6F8vFcT7sgAUeKgFrE6VSXUv
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/30/2014 03:26 PM, Wolfram Sang wrote:
> On Tue, Sep 09, 2014 at 05:31:09PM +0300, Roger Quadros wrote:
>> Some TI SoCs like DRA7 have a RAMINIT register specification
>> different from the other AMxx SoCs and as expected by the
>> existing driver.
>>
>> To add more insanity, this register is shared with other
>> IPs like DSS, PCIe and PWM.
>>
>> Provides a more generic mechanism to specify the RAMINIT
>> register location and START/DONE bit position and use the
>> syscon/regmap framework to access the register.
>>
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>> ---
>>  .../devicetree/bindings/net/can/c_can.txt          |   7 ++
>>  drivers/net/can/c_can/c_can.h                      |  11 ++-
>>  drivers/net/can/c_can/c_can_platform.c             | 109 ++++++++++++=
+++------
>>  3 files changed, 95 insertions(+), 32 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Doc=
umentation/devicetree/bindings/net/can/c_can.txt
>> index 8f1ae81..e12d1a1 100644
>> --- a/Documentation/devicetree/bindings/net/can/c_can.txt
>> +++ b/Documentation/devicetree/bindings/net/can/c_can.txt
>> @@ -13,6 +13,13 @@ Optional properties:
>>  - ti,hwmods		: Must be "d_can<n>" or "c_can<n>", n being the
>>  			  instance number
>> =20
>> +- ti,raminit-syscon	: Handle to system control region that contains t=
he
>> +			  RAMINIT register. If specified, the second memory resource
>> +			  in the reg property must index into the RAMINIT
>> +			  register within the syscon region
>=20
> There seems to be a simple "syscon" property these days.
>=20
>> +- ti,raminit-start-bit	: Bit posistion of START bit in the RAMINIT re=
gister
>> +- ti,raminit-done-bit	: Bit position of DONE bit in the RAMINIT regis=
ter
>=20
> This should not be encoded in DT! This is not describing hardware setup=
=2E
> The driver should know where the bits are for the syscon phandle,
> depending on which SoC it runs...

Is the register shared by more than one core? If so the information has
to go somewhere. Using an alias in the DT is probably the wrong approach.=


Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Ab7sQouDq6F8vFcT7sgAUeKgFrE6VSXUv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQqtAAACgkQjTAFq1RaXHO4+QCdGu0eY8rFVSylht3CRIFRm9wG
f+UAnj5Mw9MXjqJeTjjCIFVD0p4jLmD6
=lSa4
-----END PGP SIGNATURE-----

--Ab7sQouDq6F8vFcT7sgAUeKgFrE6VSXUv--

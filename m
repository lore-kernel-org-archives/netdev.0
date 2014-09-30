From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Tue, 30 Sep 2014 16:11:08 +0200
Message-ID: <542AB9FC.6060705@pengutronix.de>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com> <1410273070-22485-3-git-send-email-rogerq@ti.com> <20140930132650.GN1325@katana> <542AB400.6080608@pengutronix.de> <542AB801.6050805@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="2PWRalCkiV99Ma65x1TTR3SUuWERDFxOS"
Cc: wg@grandegger.com, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roger Quadros <rogerq@ti.com>, Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <542AB801.6050805@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--2PWRalCkiV99Ma65x1TTR3SUuWERDFxOS
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/30/2014 04:02 PM, Roger Quadros wrote:
> On 09/30/2014 04:45 PM, Marc Kleine-Budde wrote:
>> On 09/30/2014 03:26 PM, Wolfram Sang wrote:
>>> On Tue, Sep 09, 2014 at 05:31:09PM +0300, Roger Quadros wrote:
>>>> Some TI SoCs like DRA7 have a RAMINIT register specification
>>>> different from the other AMxx SoCs and as expected by the
>>>> existing driver.
>>>>
>>>> To add more insanity, this register is shared with other
>>>> IPs like DSS, PCIe and PWM.
>>>>
>>>> Provides a more generic mechanism to specify the RAMINIT
>>>> register location and START/DONE bit position and use the
>>>> syscon/regmap framework to access the register.
>>>>
>>>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>>>> ---
>>>>  .../devicetree/bindings/net/can/c_can.txt          |   7 ++
>>>>  drivers/net/can/c_can/c_can.h                      |  11 ++-
>>>>  drivers/net/can/c_can/c_can_platform.c             | 109 ++++++++++=
+++++------
>>>>  3 files changed, 95 insertions(+), 32 deletions(-)
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/D=
ocumentation/devicetree/bindings/net/can/c_can.txt
>>>> index 8f1ae81..e12d1a1 100644
>>>> --- a/Documentation/devicetree/bindings/net/can/c_can.txt
>>>> +++ b/Documentation/devicetree/bindings/net/can/c_can.txt
>>>> @@ -13,6 +13,13 @@ Optional properties:
>>>>  - ti,hwmods		: Must be "d_can<n>" or "c_can<n>", n being the
>>>>  			  instance number
>>>> =20
>>>> +- ti,raminit-syscon	: Handle to system control region that contains=
 the
>>>> +			  RAMINIT register. If specified, the second memory resource
>>>> +			  in the reg property must index into the RAMINIT
>>>> +			  register within the syscon region
>>>
>>> There seems to be a simple "syscon" property these days.
>>>
>>>> +- ti,raminit-start-bit	: Bit posistion of START bit in the RAMINIT =
register
>>>> +- ti,raminit-done-bit	: Bit position of DONE bit in the RAMINIT reg=
ister
>>>
>>> This should not be encoded in DT! This is not describing hardware set=
up.
>>> The driver should know where the bits are for the syscon phandle,
>>> depending on which SoC it runs...
>>
>> Is the register shared by more than one core? If so the information ha=
s
>> to go somewhere. Using an alias in the DT is probably the wrong approa=
ch.
>=20
> In case of the DRA7xx Soc, this syscon register is shared by multiple c=
ores. (CAN, Display, etc), sigh!!
> For AM335x and AM43xx SoCs, the register is used only for DCAN. but sha=
red by 2 DCAN instances.
>=20
> Shouldn't the information for the CAN specific bits lie in the CAN driv=
er?

As there are more than one DCAN instance on the same SOC the information
which DCAN instance uses which bits in the register has to go somewhere.
We might add these bits as the 3rd and 4th parameter to the syscon phandl=
e.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--2PWRalCkiV99Ma65x1TTR3SUuWERDFxOS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQqufwACgkQjTAFq1RaXHON4gCfY4eBC+Vs3WBjBDG9bZr2wErV
tY0An0SZa1JrLNb9GTBzTAyKXWFuzvmZ
=YbeR
-----END PGP SIGNATURE-----

--2PWRalCkiV99Ma65x1TTR3SUuWERDFxOS--

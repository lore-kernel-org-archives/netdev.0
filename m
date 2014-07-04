From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V2 1/1] net: can: Remodel FlexCAN register read/write
 APIs for BE instances
Date: Fri, 04 Jul 2014 15:53:16 +0200
Message-ID: <53B6B1CC.5080702@pengutronix.de>
References: <1404478881-21853-1-git-send-email-bhupesh.sharma@freescale.com> <53B6AEF4.6080301@pengutronix.de> <f1a24210440e496381238a53d9a23db7@BN1PR03MB220.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="JA7B9lOLici4a86j3aKP0oeLFibew2FEp"
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "bhupesh.sharma@freescale.com" <bhupesh.sharma@freescale.com>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <f1a24210440e496381238a53d9a23db7@BN1PR03MB220.namprd03.prod.outlook.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--JA7B9lOLici4a86j3aKP0oeLFibew2FEp
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/04/2014 03:47 PM, bhupesh.sharma@freescale.com wrote:
> Hi Marc,
>=20
> Thanks for your review.
>=20
>> -----Original Message-----
>> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
>> Sent: Friday, July 04, 2014 7:11 PM
>> To: Sharma Bhupesh-B45370; linux-can@vger.kernel.org
>> Cc: wg@grandegger.com; netdev@vger.kernel.org
>> Subject: Re: [PATCH V2 1/1] net: can: Remodel FlexCAN register read/wr=
ite
>> APIs for BE instances
>>
>> On 07/04/2014 03:01 PM, Bhupesh Sharma wrote:
>>> The FlexCAN IP on certain SoCs like (Freescale's LS1021A) is modelled=

>>> in a big-endian fashion, i.e. the registers and the message buffers
>>> are organized in a BE way.
>>>
>>> More details about the LS1021A SoC can be seen here:
>>> http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=3DLS10=
21A
>>> &nodeId=3D018rH325E4017B#
>>>
>>> This patch ensures that the register read/write APIs are remodelled t=
o
>>> address such cases, while ensuring that existing platforms (where the=

>>> FlexCAN IP was modelled in LE way) do not break.
>>>
>>> Tested on LS1021A-QDS board.
>>>
>>> Signed-off-by: Bhupesh Sharma <bhupesh.sharma@freescale.com>
>>> ---
>>> Changes since v1:
>>> - Addressed Marc's review comments.
>>> - Also tried on ARM big-endian kernel
>>>
>>> Rebased against v3.16-rc2
>>
>> Please use net-next or linux-can-next, but I think this makes no
>> difference here.
>>
>>>  drivers/net/can/flexcan.c |  192
>>> +++++++++++++++++++++++++++------------------
>>>  1 file changed, 114 insertions(+), 78 deletions(-)
>>
>> I'm missing the DT documentation update.
>=20
> Yes. I just wanted to get some early comments on this.
>=20
>> [...]
>>
>> 		of_property_read_u32(pdev->dev.of_node,
>>> @@ -1149,6 +1166,25 @@ static int flexcan_probe(struct platform_devic=
e
>> *pdev)
>>>  	dev->flags |=3D IFF_ECHO;
>>>
>>>  	priv =3D netdev_priv(dev);
>>> +
>>> +	if (IS_ENABLED(CONFIG_CPU_BIG_ENDIAN))
>>> +		core_is_little =3D false;
>>> +
>>> +	if (of_property_read_bool(dev->dev.of_node, "big-endian"))
>>> +		module_is_little =3D false;
>>> +
>>> +	if ((core_is_little && module_is_little) ||
>>> +	    (!core_is_little && !module_is_little)) {
>>
>> I think this is broken on PPC, where both core and module are BE. Plea=
se
>> assume native endianess an default, if neither big-endian nor little-
>> endian is present.
>=20
> On PPC platforms (which are BE) the IP is essentially LE (I verified th=
is on P1010 RDB).
>=20
> If both are BE, then we need no swap operations, right? Or am I missing=
 something.

Have a look at the existing code:

> /*
>  * Abstract off the read/write for arm versus ppc. This
>  * assumes that PPC uses big-endian registers and everything
>  * else uses little-endian registers, independent of CPU
>  * endianess.
>  */
> #if defined(CONFIG_PPC)
> static inline u32 flexcan_read(void __iomem *addr)
> {
> 	return in_be32(addr);
> }
>=20
> static inline void flexcan_write(u32 val, void __iomem *addr)
> {
> 	out_be32(addr, val);
> }
> #else

I think in_be32() does the same regarding to endianess as ioread32be()

Marc


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--JA7B9lOLici4a86j3aKP0oeLFibew2FEp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlO2scwACgkQjTAFq1RaXHN3xQCcCoCaQSfJH8YnOXbSKgG3UYhR
BKMAnjI9K9GFE7Q+v4xWS1aO/uJRAzk3
=kRSc
-----END PGP SIGNATURE-----

--JA7B9lOLici4a86j3aKP0oeLFibew2FEp--

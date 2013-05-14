From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net/macb: fix ISR clear-on-write behavior only for some
 SoC
Date: Tue, 14 May 2013 09:49:41 +0200
Message-ID: <5191EC95.2020704@monstr.eu>
References: <1368461105-23128-1-git-send-email-nicolas.ferre@atmel.com> <FE065E51-1EAA-47ED-8C7B-0F2E6418F349@jcrosoft.com> <51918C23.7040106@yahoo.es> <20130514055256.GD22508@game.jcrosoft.org> <5191E53B.9000106@yahoo.es> <C35C1E42-FCD6-4EE7-902B-FE01F362CD40@jcrosoft.com> <5191E855.5090908@yahoo.es>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2WTVVSNRMSCPPHPFBEQOU"
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	michal.simek@xilinx.com,
	Ludovic Desroches <ludovic.desroches@atmel.com>,
	s.trumtrar@pengutronix.de, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Hein Tibosch <hein_tibosch@yahoo.es>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5191E855.5090908@yahoo.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2WTVVSNRMSCPPHPFBEQOU
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 05/14/2013 09:31 AM, Hein Tibosch wrote:
> On 5/14/2013 3:22 PM, Jean-Christophe PLAGNIOL-VILLARD wrote:
>> On May 14, 2013, at 3:18 PM, Hein Tibosch <hein_tibosch@yahoo.es> wrot=
e:
>>
>>> On 5/14/2013 1:52 PM, Jean-Christophe PLAGNIOL-VILLARD wrote:
>>>> On 08:58 Tue 14 May     , Hein Tibosch wrote:
>>>>> On 5/14/2013 12:05 AM, Jean-Christophe PLAGNIOL-VILLARD wrote:
>>>>>> On May 14, 2013, at 12:05 AM, Nicolas Ferre <nicolas.ferre@atmel.c=
om> wrote:
>>>>>>
>>>>>>> Commit 749a2b6 (net/macb: clear tx/rx completion flags in ISR)
>>>>>>> introduces clear-on-write on ISR register. This behavior is not a=
lways
>>>>>>> implemented when using Cadence MACB/GEM and is breaking other pla=
tforms.
>>>>>>> We are using a new Device Tree compatibility string and a capabil=
ity
>>>>>>> property to actually activate this clear-on-write behavior on ISR=
=2E
>>>>>>>
>>>>>>> Reported-by: Hein Tibosch <hein_tibosch@yahoo.es>
>>>>>>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>>>>>> can we detect it via the IP?
>>>>> This was my first proposal, have it based on the value of MACB's
>>>>> register 'MID' (offset 0x00fc, lower 16 bits).
>>>>> On avr32 it reads: 0x0000010D, on Zynq it reports 0x00000119
>>>>>
>>>>> So for the moment, CAPS_ISR_CLEAR_ON_WRITE could be set if the revi=
sion
>>>>> equals to 0x00000119?
>>>> so no it will not work
>>>>
>>>> as the gem on sama5 is 00020119
>>>>
>>>> so version 0x119 too
>>>>
>>>> nico
>>> All right, that's a pity.
>>>
>>> The only issue that remains then is the obligation to use CONFIG_OF,
>>> or:
>>>
>>> +#if defined(CONFIG_OF)
>>> +	dev_id =3D of_match_device(macb_dt_ids, &pdev->dev);
>>> +	if (dev_id)
>>> +		bp->caps =3D (u32)dev_id->data;
>>> +
>>> +#endif
>>>
>>> ?
>> no need as of_match_device is a inline of !OF
> Sorry, here's the complete compiler error:
> drivers/net/ethernet/cadence/macb.c: In function 'macb_probe':
> drivers/net/ethernet/cadence/macb.c:1601: error: 'macb_dt_ids' undeclar=
ed (first use in this function)
>=20
> Earlier, 'macb_dt_ids' is only defined when using OF

The trick is in using of_match_ptr. It means remove that CONFIG_OF around=
 macb_dt_ids too.

[linux-2.6.x]$ grep -rn "of_match_ptr" include/linux/
include/linux/of.h:314:#define of_match_ptr(_ptr)	(_ptr)
include/linux/of.h:508:#define of_match_ptr(_ptr)	NULL

Thanks,
Michal



--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



------enig2WTVVSNRMSCPPHPFBEQOU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGR7JUACgkQykllyylKDCHnLQCbBzvFzVTpd6noblmVs5eogHar
EpoAnjDcD2DKIdcQ/z24f9OcocrSBOWt
=lJNr
-----END PGP SIGNATURE-----

------enig2WTVVSNRMSCPPHPFBEQOU--

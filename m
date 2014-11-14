From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2] can: Fix bug in suspend/resume
Date: Fri, 14 Nov 2014 16:09:35 +0100
Message-ID: <54661B2F.2000704@pengutronix.de>
References: <e7070431858e49e29cd03d76fd7a66c3@BN1AFFO11FD055.protection.gbl> <5465C34D.4030805@pengutronix.de> <e5f5913b51a54222aa1bb0680a77e56d@BN1AFFO11FD055.protection.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="XdXl35NW4fHGW2gSn9bhxeK9AIp5bHaER"
Cc: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	wg@grandegger.com, michal.simek@xilinx.com,
	grant.likely@linaro.org, robh+dt@kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org,
	Kedareswara rao Appana <appanad@xilinx.com>
To: =?UTF-8?B?U8O2cmVuIEJyaW5rbWFubg==?= <soren.brinkmann@xilinx.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <e5f5913b51a54222aa1bb0680a77e56d@BN1AFFO11FD055.protection.gbl>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XdXl35NW4fHGW2gSn9bhxeK9AIp5bHaER
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/14/2014 04:05 PM, S=C3=B6ren Brinkmann wrote:
> On Fri, 2014-11-14 at 09:54AM +0100, Marc Kleine-Budde wrote:
>> On 11/14/2014 09:16 AM, Kedareswara rao Appana wrote:
>>> The drvdata in the suspend/resume is of type struct net_device,
>>> not the platform device.Enable the clocks in the suspend before
>>> accessing the registers of the CAN.
>>>
>>> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
>>> ---
>>> Changes for v2:
>>>   - Removed the struct platform_device* from suspend/resume
>>>     as suggest by Lothar.
>>>   - The clocks are getting disabled and un prepared at the end of the=
 probe.=20
>>>     In the suspend the driver is doing a register write.In order
>>>     To do that register write we have to again enable and prepare the=
 clocks.
>>
>> Please look the at suspend/resume code and count the
>> clock_enable/disable manually. After a suspend/resume cycle, you have
>> enabled the clock twice, but disabled it once.
>>
>> I think you have to abstract the clock handling behind runtime PM. I
>> haven't done this myself yet, but the strong feeling that this is a
>> possible solution to your problem. These links might help:
>=20
> I agree, the clock handling looks weird. Also the clk_disable calls in
> xcan_get_berr_counter() look suspicious to me, but I might be wrong.
> I think you can take a look at gpio-zynq for an example for runtime_pm
> usage. I think the usage model in that driver is similar to here.

The xcan_get_berr_counter() function is correct, when doing manual (i.e.
non runtime-pm) clock handling. This function might be called if the
interface is down, this means clocks are disabled.

Marc


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--XdXl35NW4fHGW2gSn9bhxeK9AIp5bHaER
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZhsvAAoJECte4hHFiupU2aAP/1D4UmAQsWEyj2226J7eYpw0
MYnRj9cGOU/veX16llKdizrOb1dsbkfIyp8oAeDhAl0jjTQGySZdP3I6kzZ4nX5T
1lGSHJPSTY77qFWEGiOPb1qM45+j9Euk6qxtNjiqXhjYAId/t5oD6zAcwZvxDnI1
xyUTQe2iK+x6ljFUSJ08hBxVJg5CivVrc1mwQWyjrHE4sfRa/n63clAReh1W6oV7
3Mv85DdMhdylPq34LowW+t70e5Yel9tGYwaACaleR1JILk+TJQ4zG5qUpr8gxRRb
UPuS4JvWbtzRNCbjiEBCwUPMPaZp29D/NLM7icNYr78hOkwgqoaZ4eTm0T/K4yMv
AMdpLCXTLvshQ8aoUi6dktpSS/nzlH2tWjm7tAUubqekcUic2uRj/Y14bQu5CXc7
m9+goKBwVzxKGtVRaPi3PMq6hSsSVrhiFQuTg4HpJN1dgkCapFfyUKV9g9EFdrnn
VonI+ocR3GEju2k13WUv5qqyYVzeNiU3vdZQ9XItr4FhUpJbPFfGhkAzfU26HHv7
5tBqw6pytDwC0XYSSSMEAYi2MX0DrGdisEYEcQo4wQG69RR7jQQC3vYLR77QmeDg
YPMgWpZqPDDxeIaQl35b+79Bp/V9QLmwZalq4Q7tcqC6UNMkXjrVaA9lVHggEFCv
4PY24kbmUITh4gO+sk76
=mcbj
-----END PGP SIGNATURE-----

--XdXl35NW4fHGW2gSn9bhxeK9AIp5bHaER--

From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 08 Aug 2011 17:14:35 +0200
Message-ID: <4E3FFD5B.7080000@pengutronix.de>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>	<1312641270-6018-6-git-send-email-holt@sgi.com>	<4E3FA066.3020301@grandegger.com>
	<20110808113136.GS4926@sgi.com>	<4E3FDFC9.7080508@grandegger.com>
	<20110808135630.GU4926@sgi.com>	<4E3FEFBB.9050103@grandegger.com>
	<20110808142153.GW4926@sgi.com>	<4E3FF4B8.2010603@grandegger.com>
	<20110808144424.GY4926@sgi.com> <4E3FF9EA.6030601@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2020793200202333631=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E3FF9EA.6030601-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============2020793200202333631==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigA90A252B08B8160AC29C3C6D"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigA90A252B08B8160AC29C3C6D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/08/2011 04:59 PM, Wolfgang Grandegger wrote:
> On 08/08/2011 04:44 PM, Robin Holt wrote:
>> On Mon, Aug 08, 2011 at 04:37:44PM +0200, Wolfgang Grandegger wrote:
>>> On 08/08/2011 04:21 PM, Robin Holt wrote:
>>>> On Mon, Aug 08, 2011 at 04:16:27PM +0200, Wolfgang Grandegger wrote:=

>>>>> On 08/08/2011 03:56 PM, Robin Holt wrote:
>>>>>>> commit 65bb8b060a873fa4f5188f2951081f6011259614
>>>>>>> Author: Bhaskar Upadhaya <Bhaskar.Upadhaya-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>>>>>>> Date:   Fri Mar 4 20:27:58 2011 +0530
>>>>>>
>>>>>> On a side note, that commit fixes up "fsl,flexcan-v1.0"
>>>>>> ...
>>>>>> +       do_fixup_by_compat_u32(blob, "fsl,flexcan-v1.0",
>>>>>> +                       "clock_freq", gd->bus_clk, 1);
>>>>>>
>>>>>> Should I go back to flexcan-v1.0 in my patches?
>>>>>
>>>>> Well, no. Let's wait. I don't think we need it. Also, it sets
>>>>> "clock_freq" while
>>>>>
>>>>>  http://lxr.linux.no/#linux+v3.0.1/Documentation/devicetree/binding=
s/net/can/fsl-flexcan.txt
>>>>>
>>>>> documents "clock-frequencies"... :-(.
>>>>
>>>> You answered a different question that I was asking.  I was asking i=
f
>>>> I should change fsl,flexcan back to fsl,flexcan-v1.0 as documented o=
n
>>>> line 5.  The clock_freq looks like a uboot change will need to be ma=
de
>>>> as well.
>>>
>>> Well, I wrote above: "Well, no. Let's wait. I don't think we need it.=
"
>>>
>>> For the P1010 we can sinmply derive the clock frequency from
>>> "fsl_get_sys_freq()", which is fine for the time being. No extra
>>> properties, etc. The clk implemetation might go into
>>>
>>>  http://lxr.linux.no/#linux+v3.0.1/arch/powerpc/platforms/85xx/clock.=
c
>>>
>>> or
>>>
>>>  http://lxr.linux.no/#linux+v3.0.1/arch/powerpc/sysdev/fsl_soc.c
>>>
>>> And may depend on HAVE_CAN_FLEXCAN
>>>
>>> BTW, I have not found HAVE_CAN_FLEXCAN in your patch. What kernel are=

>>> you using?
>>
>> I am starting with the v3.0 kernel, apply one patch from the freescale=
 BSP
>> we receive under NDA which introduces the P1010RDB board into the QorI=
Q
>> platform, and then work from there for the flexcan stuff.  That patch
>> introduces the HAVE_CAN_FLEXCAN.  I do not like how freescale structur=
ed
>> that Kconfig bit, so I have tweaked it to be selected automatically
>> when P1010RDB, NET, and CAN are selected.  That allows the CAN_FLEXCAN=

>> selection to determine is we are going to build the flexcan.c file.
>=20
> ARM boards select HAVE_CAN_FLEXCAN and I do not see a good reason why
> we should do it differently for PowerPC.=20
>=20
> For mainline inclusion, you should provide your patches against the
> David Millers "net-next-2.6" tree, which already seems to have support
> for the P1010RDB:
>=20
>   config P1010_RDB
>         bool "Freescale P1010RDB"
>         select DEFAULT_UIMAGE
>         help
>           This option enables support for the MPC85xx RDB (P1010 RDB) b=
oard
>=20
>           P1010RDB contains P1010Si, which provides CPU performance up =
to 800
>           MHz and 1600 DMIPS, additional functionality and faster inter=
faces
>           (DDR3/3L, SATA II, and PCI  Express).
>=20
>=20
>> Our contact with Freescale would prefer that I not post that patch unt=
il
>> we get the OK from freescale to do so since we received it under NDA.
>=20
> I don't think we currently need it. I prefer dropping and cleaning up
> the device tree stuff as it is not needed for the P1010 anyway. If a
> new processor shows up with enhanced capabilities requiring
> configuration via device tree, we or somebody else can provide a patch.=

> Marc, what do you think?

ACK - The device tree bindings as in mainline's Documentation is a mess.
If the powerpc guys are happy with a clock interfaces based approach
somewhere in arch/ppc, I'm more than happy to remove:
- fsl,flexcan-clock-source (not implemented, even in the fsl driver)

- fsl,flexcan-clock-divider \__ replace with code in arch/ppc, or
- clock-frequency           /   a single clock-frequency attribute

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigA90A252B08B8160AC29C3C6D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4//V0ACgkQjTAFq1RaXHPtawCdFGIX3AFuPdtbN2TajN3OaYAl
uJkAn23zpYEKbdGTg3PX0T1T+mIOm5cB
=njGv
-----END PGP SIGNATURE-----

--------------enigA90A252B08B8160AC29C3C6D--

--===============2020793200202333631==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============2020793200202333631==--

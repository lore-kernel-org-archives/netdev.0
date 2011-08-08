From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [RFC 5/5] [powerpc] Implement a p1010rdb clock source.
Date: Mon, 08 Aug 2011 16:19:20 +0200
Message-ID: <4E3FF068.6070905@pengutronix.de>
References: <1312641270-6018-1-git-send-email-holt@sgi.com>
	<1312641270-6018-6-git-send-email-holt@sgi.com>
	<4E3FA066.3020301@grandegger.com> <20110808113136.GS4926@sgi.com>
	<4E3FDFC9.7080508@grandegger.com> <4E3FE844.6090005@pengutronix.de>
	<20110808140340.GV4926@sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0307505944594449060=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110808140340.GV4926-sJ/iWh9BUns@public.gmane.org>
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
--===============0307505944594449060==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig981C9112388A60DB23DFCF39"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig981C9112388A60DB23DFCF39
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/08/2011 04:03 PM, Robin Holt wrote:
> On Mon, Aug 08, 2011 at 03:44:36PM +0200, Marc Kleine-Budde wrote:
>> On 08/08/2011 03:08 PM, Wolfgang Grandegger wrote:
>>> On 08/08/2011 01:31 PM, Robin Holt wrote:
>>>> On Mon, Aug 08, 2011 at 10:37:58AM +0200, Wolfgang Grandegger wrote:=

>>>>> On 08/06/2011 04:34 PM, Robin Holt wrote:
>>>>>> flexcan driver needs the clk_get, clk_get_rate, etc functions
>>>>>> to work.  This patch provides the minimum functionality.
>>>>>
>>>>> This needs some more general thoughts... apart from the question wh=
ere
>>>>> the code should go.
>>>>>
>>>>> Like for the MSCAN on the MPC5200, the user should be *able* to sel=
ect
>>>>> an appropriate clock source and divider via DTS node properties.
>>>>> Currently it seems, that the DTS properties must match some
>>>>> pre-configured values, most likely set by the boot loader. Please
>>>>> correct me if I'm wrong. For me this is generic and should go into =
the
>>>>> Flexcan driver. From there, a platform specific function, e.g.
>>>>> flexcan_set_clock() might be called.
>>>>
>>>> OK.  Dug a bit more.  The p1010 built-in clocksource seems to be the=

>>>> periphereal clock frequency which is system bus frequency divided
>>>> by 2.  The clock source can not be changed, but the clock divider ca=
n
>>>> by freezing the interface and setting the CTRL register.  This appea=
rs
>>>> to only be done by the boot loader.  I do not see why we can not lea=
ve
>>>
>>> And likely Freescale's bootloader does also fixup the DTS Flexcan nod=
e.
>>> Ah, oh, there's already someting in the mainline U-BOOT:
>>>
>>> commit 65bb8b060a873fa4f5188f2951081f6011259614
>>> Author: Bhaskar Upadhaya <Bhaskar.Upadhaya-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>>> Date:   Fri Mar 4 20:27:58 2011 +0530
>>>
>>>     powerpc/85xx: Fix up clock_freq property in CAN node of dts
>>>
>>>     Fix up the device tree property associated with the Flexcan clock=

>>>     frequency. This property is used to calculate the bit timing para=
meters
>>>     for Flexcan.
>>>
>>>     Signed-off-by: Bhaskar Upadhaya <Bhaskar.Upadhaya-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>>>     Signed-off-by: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
>>>
>>>
>>>> that functionality in the boot loader and then go back to a variatio=
n
>>>> on my earlier flexcan_clk_* patch.  Is that close to the direction y=
ou
>>>> think we should go or have I completely misunderstood your wishes?
>>>
>>> The boot loader might not chose the optimum clock source and frequenc=
y,
>>> which might even be application dependent. Therefore it would be nice=
 to
>>> allow the user to change it if necessary. Some CAN interfaces do even=

>>> allow to use an external clock source. The main question is where we =
add
>>> that functionality. As more as I think of it, the clock interface wou=
ld
>>> not be that bad, especially if it's available.
>>>
>>> Furthermore, if the bootloader sets the clock source and divider, we =
do
>>> not need device tree properties for it. A simply register lookup woul=
d
>>> reveal what values are used. We may just need the input clock source.=

>>
>> If the bootloader touches the divider _in_ the flexcan core, that woul=
d
>> make absolutely no sense. The clock divider in the flexcan core (in th=
e
>> CTRL register) is the bitrate pre-scaler calculated by the bit-timing
>> algorithm.
>>
>> What we need in the device tree is, from my point of view.
>> a) the used clock source (bus clock or xtal clock)
>> b) the frequency of that clock
>>
>> These problems are solved on arm via:
>> a) bus clock is hard coded [1]
>> b) get that clock frequency via clk_get_rate().
>=20
> Just to make sure I understand correctly, the clk_get_rate() return
> value comes from the device tree and a mach specific handler, right?
> And 'mach-specific' really means what, a processor family?

I'm talking about the mainline driver, that has no device tree support.
The clock stuff on arm currently goes like this:

The driver asks for the clock related to the device. The architecture
code has previously connected the flexcan device to an arch specific
(i.mx25, i.mx35) clock. That clock is returned. Enable/disable/get_rate
are working on that specific clock.

hope that helps, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig981C9112388A60DB23DFCF39
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk4/8GsACgkQjTAFq1RaXHMUPACePmv7yHZ0N51BjXTFaTnw8tmd
5YMAn0Vln7VYC072a6dxcacLEeEO+QTY
=9k1n
-----END PGP SIGNATURE-----

--------------enig981C9112388A60DB23DFCF39--

--===============0307505944594449060==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============0307505944594449060==--

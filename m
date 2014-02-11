From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH] can: xilinx CAN controller support.
Date: Tue, 11 Feb 2014 12:45:31 +0100
Message-ID: <da80c522-5524-4f53-9373-3f2bb6f81ddc@CO9EHSMHS015.ehs.local>
References: <6c2bcce0-9897-4d1d-a8b9-47924e40f73c@VA3EHSMHS008.ehs.local> <52F382D5.6090706@pengutronix.de> <8b4dad82-c72a-4e1f-b1af-b8c7964bbf24@TX2EHSMHS043.ehs.local> <52F4A960.10809@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="JaxILsq4rGx903n6X379Vge7eAxE5kk1O"
Cc: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52F4A960.10809@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--JaxILsq4rGx903n6X379Vge7eAxE5kk1O
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Marc,

On 02/07/2014 10:37 AM, Marc Kleine-Budde wrote:
> On 02/07/2014 09:42 AM, Appana Durga Kedareswara Rao wrote:
>>>> ---
>>>> This patch is rebased on the 3.14 rc1 kernel.
>>>> ---
>>>>  .../devicetree/bindings/net/can/xilinx_can.txt     |   43 +
>>>>  drivers/net/can/Kconfig                            |    8 +
>>>>  drivers/net/can/Makefile                           |    1 +
>>>>  drivers/net/can/xilinx_can.c                       | 1150 +++++++++++=
+++++++++
>>>>  4 files changed, 1202 insertions(+), 0 deletions(-)  create mode
>>>> 100644 Documentation/devicetree/bindings/net/can/xilinx_can.txt
>>>>  create mode 100644 drivers/net/can/xilinx_can.c
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/can/xilinx_can.txt
>>>> b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
>>>> new file mode 100644
>>>> index 0000000..34f9643
>>>> --- /dev/null
>>>> +++ b/Documentation/devicetree/bindings/net/can/xilinx_can.txt
>>>> @@ -0,0 +1,43 @@
>>>> +Xilinx Axi CAN/Zynq CANPS controller Device Tree Bindings
>>>> +---------------------------------------------------------
>>>> +
>>>> +Required properties:
>>>> +- compatible               : Should be "xlnx,zynq-can-1.00.a" for Zyn=
q
>>> CAN
>>>> +                     controllers and "xlnx,axi-can-1.00.a" for Axi CA=
N
>>>> +                     controllers.
>>>> +- reg                      : Physical base address and size of the Ax=
i CAN/Zynq
>>>> +                     CANPS registers map.
>>>> +- interrupts               : Property with a value describing the int=
errupt
>>>> +                     number.
>>>> +- interrupt-parent : Must be core interrupt controller
>>>> +- clock-names              : List of input clock names - "ref_clk",
>>> "aper_clk"
>>>> +                     (See clock bindings for details. Two clocks are
>>>> +                      required for Zynq CAN. For Axi CAN
>>>> +                      case it is one(ref_clk)).
>>>> +- clocks           : Clock phandles (see clock bindings for details).=

>>>> +- xlnx,can-tx-dpth : Can Tx fifo depth (Required for Axi CAN).
>>>> +- xlnx,can-rx-dpth : Can Rx fifo depth (Required for Axi CAN).
>>>> +
>>>> +
>>>> +Example:
>>>> +
>>>> +For Zynq CANPS Dts file:
>>>> +   zynq_can_0: zynq-can@e0008000 {
>>>> +                   compatible =3D "xlnx,zynq-can-1.00.a";
>>>> +                   clocks =3D <&clkc 19>, <&clkc 36>;
>>>> +                   clock-names =3D "ref_clk", "aper_clk";
>>>> +                   reg =3D <0xe0008000 0x1000>;
>>>> +                   interrupts =3D <0 28 4>;
>>>> +                   interrupt-parent =3D <&intc>;
>>>
>>> Above xlnx,can-{rx,tx}-dpth is mentioned as required, but it's not in t=
he
>>> Zynq example.
>>
>> One of the Difference b/w the AXI CAN and zynq CAN is in AXI CAN the fif=
o depth(tx,rx)
>> Is user configurable. But in case of ZYNQ CAN  the fifo depth  is fixed =
for tx and rx fifo's(64)
>> Xlnx,can-{rx,tx}-dpth is required only for AXI CAN case it is not requir=
ed for zynq CAN.
>> That's why didn't putted that property in device tree.
> =

> The device tree should be a hardware only description and should not
> hold any user configurable data. Please split your patch into two
> patches. The first one should add the driver with a fixed fifo size
> (e.g. 0x40) for the AXI, too. The second patch should make the fifo
> configurable via device tree.

can-rx/tx-dpth is not user configurable data as you think.
This is FPGA where you can configure this parameter in design tools.
It means these 2 values just describe real hardware and user can't just cha=
nge it
for different software behaviour.

Also I don't think it is worth to create 2 patches for the same driver
where the first one is useless for axi can device. But if you think
that it is worth to do we can create 2 patches as you suggested.

Also what we can do is to define that this property is required also
for zynq which is 0x40 and change code according too.

> If it's acceptable to describe the fifo usage by device tree, I'd like
> to make it a generic CAN driver option. But we have to look around, e.g.
> what the Ethernet driver use to configure their hardware.

I think the real question is not if this is acceptable or not. It is just
reality that we can setup hardware fifo depth and driver has to reflect thi=
s
because without it driver just doesn't work for axi can.

The only remaining question is if we should create generic DT binding
for fifo depth. Arnd, Rob: Any opinion about it?
Definitely will be worth to have one generic binding if this is generic fea=
ture.
But if this is just specific feature for us then current properties should
be fine.

In general all these xlnx,XXX properties just reflect all configurable opti=
ons
which you can setup in design tool which means that provide full hw descrip=
tion
with all variants and they are automatically generated from tools.

Please let me know what you think.

Thanks,
Michal


--JaxILsq4rGx903n6X379Vge7eAxE5kk1O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlL6DVsACgkQykllyylKDCHZhwCeJkO74M5tOGQGTPL56zp1YxtK
WugAoIJWLpKIIElilRGyKZzdMVed0D8C
=1jFI
-----END PGP SIGNATURE-----


--JaxILsq4rGx903n6X379Vge7eAxE5kk1O--

From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH 05/13] ARM: dts: DRA7: Add DCAN nodes
Date: Tue, 9 Sep 2014 11:30:50 +0300
Message-ID: <540EBABA.9090009@ti.com>
References: <1410185442-907-1-git-send-email-rogerq@ti.com> <1410185442-907-6-git-send-email-rogerq@ti.com> <540DDBE0.5090004@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <tglx@linutronix.de>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<wg@grandegger.com>, <mkl@pengutronix.de>, <tony@atomide.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <540DDBE0.5090004@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 09/08/2014 07:40 PM, Sergei Shtylyov wrote:
> Hello.
>=20
> On 9/8/2014 6:10 PM, Roger Quadros wrote:
>=20
>> The SoC supports 2 DCAN nodes. Add them.
>=20
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>> ---
>>   arch/arm/boot/dts/dra7.dtsi | 30 ++++++++++++++++++++++++++++++
>>   1 file changed, 30 insertions(+)
>=20
>> diff --git a/arch/arm/boot/dts/dra7.dtsi b/arch/arm/boot/dts/dra7.dt=
si
>> index 370009e..4ce1a4f 100644
>> --- a/arch/arm/boot/dts/dra7.dtsi
>> +++ b/arch/arm/boot/dts/dra7.dtsi
> [...]
>> @@ -1267,6 +1269,34 @@
>>               ti,irqs-skip =3D <10 133 139 140>;
>>               ti,irqs-safe-map =3D <0>;
>>           };
>> +
>> +        dcan1: d_can@481cc000 {
>=20
>    The ePAPR standard has something to say here:
>=20
>>>
> The name of a node should be somewhat generic, reflecting the functio=
n of the device and not its precise programming model. If appropriate, =
the name should be one of the following choices:
>=20
>     =95 can

Right. I'll fix it up.

>>>
>=20
>> +            compatible =3D "bosch,d_can";
>> +            ti,hwmods =3D "dcan1";
>> +            reg =3D <0x4ae3c000 0x2000>,
>> +                  <0x558 0x4>; /* index to RAMINIT reg within sysco=
n */
>> +            raminit-syscon =3D <&dra7_ctrl_core>;
>> +            raminit-start-bit =3D <3>;
>> +            raminit-done-bit =3D <1>;
>> +            raminit-pulse;
>=20
>    Hm, aren't the above 4 properties vendor specific? If so, they sho=
uld start with a vendor prefix and comma.

At least for now I don't know about any other platform other than TI us=
ing a RAMINIT register outside the
CAN register space. However the mechanism is generic enough and not lim=
ited to TI platforms.

I don't mind vendor prefix or not, but would like to hear the opinion o=
f the CAN maintainers as to what they would prefer.

>=20
>> +            interrupts =3D <GIC_SPI 222 IRQ_TYPE_LEVEL_HIGH>;
>> +            clocks =3D <&dcan1_sys_clk_mux>;
>> +            status =3D "disabled";
>> +        };
>=20

cheers,
-roger

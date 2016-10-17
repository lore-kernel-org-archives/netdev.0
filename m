From: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
Subject: Re: [PATCH 06/10] gpio: sam: Document bindings of SAM FPGA GPIO block
Date: Mon, 17 Oct 2016 22:01:39 +0300
Message-ID: <59521A70-4897-4F10-B757-E25245F8E05E@konsulko.com>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com> <1475853518-22264-7-git-send-email-pantelis.antoniou@konsulko.com> <20161010200346.GA24239@rob-hp-laptop>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: Lee Jones <lee.jones@linaro.org>,
        Linus Walleij <linus.walleij@linaro.org>,
        Alexandre Courbot <gnurou@gmail.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Frank Rowand <frowand.list@gmail.com>,
        Wolfram Sang <wsa@the-dreams.de>,
        David Woodhouse <dwmw2@infradead.org>,
        Brian Norris <computersforpeace@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Wim Van Sebroeck <wim@iguana.be>,
        Peter Rosin <peda@axentia.se>,
        Debjit Ghosh <dghosh@juniper.net>,
        Georgi Vlaev <gvlaev@juniper.net>,
        Guenter Roeck <linux@roeck-us.net>,
        Maryam Seraj <mseraj@juniper.net>, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-gpio@vger.kernel.org,
        linux-i2c@vger.kernel.org, linux-mtd@lists.infradead.org,
        linux-watchdog@vger.kernel.org, netdev@vger.kernel.org
To: Rob Herring <robh@kernel.org>
Return-path: <linux-i2c-owner@vger.kernel.org>
In-Reply-To: <20161010200346.GA24239@rob-hp-laptop>
Sender: linux-i2c-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rob,

> On Oct 10, 2016, at 23:03 , Rob Herring <robh@kernel.org> wrote:
>=20
> On Fri, Oct 07, 2016 at 06:18:34PM +0300, Pantelis Antoniou wrote:
>> From: Georgi Vlaev <gvlaev@juniper.net>
>>=20
>> Add device tree bindings document for the GPIO driver of
>> Juniper's SAM FPGA.
>>=20
>> Signed-off-by: Georgi Vlaev <gvlaev@juniper.net>
>> [Ported from Juniper kernel]
>> Signed-off-by: Pantelis Antoniou <pantelis.antoniou@konsulko.com>
>> ---
>> .../devicetree/bindings/gpio/jnx,gpio-sam.txt      | 110 =
+++++++++++++++++++++
>> 1 file changed, 110 insertions(+)
>> create mode 100644 =
Documentation/devicetree/bindings/gpio/jnx,gpio-sam.txt
>>=20
>> diff --git a/Documentation/devicetree/bindings/gpio/jnx,gpio-sam.txt =
b/Documentation/devicetree/bindings/gpio/jnx,gpio-sam.txt
>> new file mode 100644
>> index 0000000..514c350
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/gpio/jnx,gpio-sam.txt
>> @@ -0,0 +1,110 @@
>> +Juniper SAM FPGA GPIO block
>> +
>> +The controller's registers are organized as sets of eight 32-bit
>> +registers with each set controlling a bank of up to 32 pins.  A =
single
>> +interrupt is shared for all of the banks handled by the controller.
>> +
>> +Required properties:
>> +
>> +- compatible:
>> +    Must be "jnx,gpio-sam"
>> +
>> +- #gpio-cells:
>> +    Should be <2>.  The first cell is the pin number (within the =
controller's
>> +    pin space), and the second is used for the following flags:
>> +	bit[0]: direction (0 =3D out, 1 =3D in)
>> +	bit[1]: init high
>> +	bit[2]: active low
>> +	bit[3]: open drain
>> +	bit[4]: open drain
>=20
> Use and/or add to standard flags.
>=20

OK.

>> +
>> +- gpio-controller:
>> +    Specifies that the node is a GPIO controller.
>> +
>> +Optional properties:
>> +
>> +- reg:
>> +    This driver is part of the SAM FPGA MFD driver, so the
>> +    address range is supplied by that driver. However you can
>> +    override using this property.
>> +
>> +- gpio-base:
>> +    Base of the GPIO pins of this instance. If not present use =
system allocated.
>=20
> This probably needs to go.
>=20

OK.

>> +
>> +- gpio-count:
>=20
> ngpios instead.
>=20

OK.

>> +    Number of GPIO pins of this instance. If not present read the =
number from
>> +    the one configured in the FPGA data. Maximum number is 512.
>> +
>> +- #interrupt-cells:
>> +    Should be <2>.  The first cell is the GPIO number, the second =
should specify
>> +    flags.  The following subset of flags is supported:
>> +    - bits[16,4:0] trigger type and level flags
>> +	bit  0: rising edge interrupt
>> +	bit  1: falling edge interrupt
>> +	bit  2: active high interrupt
>> +	bit  3: active low interrupt
>> +	bit  4: enable debounce
>> +	bit 16: signal is active low
>=20
> What does this mean?
>=20

I will reword.

>> +    See also =
Documentation/devicetree/bindings/interrupt-controller/interrupts.txt
>> +
>> +- gpio-interrupts:
>> +    A number of triples that define the mapping of interrupt groupsb =
to a range of
>> +    pins. The first cell defines the interrupt group, the second is =
the start of
>> +    the pin range and the third the number of pins in the range.
>=20
> Needs a vendor prefix.
>=20

OK.

>> +
>> +- gpio-exports:
>> +    A subnode containing the list of pins that will be exported to =
user-space.
>=20
> DT doesn't know about userspace. Drop this.
>=20

OK, the export bit should go.=20

>> +    Each subnode contains:
>> +    Required properties:
>> +	- pin: The gpio to be exported and the relevant flags.
>> +    Optional properties:
>> +        - label: The label to use for export; if not supplied use =
the node name.
>> +
>> +Example:
>> +
>> +gpio20: gpio-sam {
>> +	compatible =3D "jnx,gpio-sam";
>> +	gpio-controller;
>> +	interrupt-controller;
>> +	/* 1st cell: gpio pin
>> +	 * 2nd cell: flags (bit mask)
>> +	 * bit  0: rising edge interrupt
>> +	 * bit  1: falling edge interrupt
>> +	 * bit  2: active high interrupt
>> +	 * bit  3: active low interrupt
>> +	 * bit  4: enable debounce
>> +	 * bit 16: signal is active low
>> +	 */
>> +	#interrupt-cells =3D <2>;
>> +	#gpio-cells =3D <2>;
>> +	gpio-count =3D <340>;
>> +	/* 1st cell: gpio interrupt status bit
>> +	 * 2nd cell: 1st pin
>> +	 * 3rd cell: # of pins
>> +	 */
>> +	gpio-interrupts =3D
>> +		<0 0 32>,	/* TL / TQ */
>> +		<1 32 32>,	/* PIC 1 */
>> +		<2 32 32>,	/* PIC 1 spare */
>> +		<7 148 32>,	/* PIC 0 */
>> +		<8 170 32>,	/* PIC 0 spare */
>> +		<16 318 22>;	/* FPC */
>> +
>> +	gpio-exports {
>> +		/*
>> +		 * flags:
>> +		 * GPIOF_DIR_IN			bit 0=3D1
>> +		 * GPIOF_DIR_OUT		bit 0=3D0
>> +		 * GPIOF_INIT_HIGH		bit 1=3D1
>> +		 *   GPIOF_INIT_HIGH is raw, not translated
>> +		 * GPIOF_ACTIVE_LOW		bit 2=3D1
>> +		 * GPIOF_OPEN_DRAIN		bit 3=3D1
>> +		 * GPIOF_OPEN_SOURCE		bit 4=3D1
>> +		 * GPIOF_EXPORT			bit 5=3D1
>> +		 * GPIOF_EXPORT_CHANGEABLE      bit 6=3D1
>> +		 */
>> +		tl0-rst {
>> +			pin =3D < 8 0x24 >;
>> +		};
>> +	};
>> +};
>> --=20
>> 1.9.1

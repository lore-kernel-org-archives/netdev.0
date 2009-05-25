From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [net-next-2.6 PATCH v2] can: SJA1000: generic OF platform bus
	driver
Date: Mon, 25 May 2009 00:53:02 -0600
Message-ID: <fa686aa40905242353v21c08209x2e443f42ef4096fa@mail.gmail.com>
References: <4A16BAAE.3070401@grandegger.com> <fa686aa40905220808kecd06cdqb570b78ca97f0ca6@mail.gmail.com>
	<4A1797C5.1040907@grandegger.com> <4A182800.2090204@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	devicetree-discuss <devicetree-discuss@ozlabs.org>,
	linuxppc-dev <Linuxppc-dev@ozlabs.org>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:46938 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156AbZEYGxU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2009 02:53:20 -0400
Received: by yx-out-2324.google.com with SMTP id 3so1768233yxj.1
        for <netdev@vger.kernel.org>; Sun, 24 May 2009 23:53:22 -0700 (PDT)
In-Reply-To: <4A182800.2090204@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 23, 2009 at 10:44 AM, Wolfgang Grandegger <wg@grandegger.co=
m> wrote:
> Wolfgang Grandegger wrote:
>> Grant Likely wrote:
>>>> +- clock-frequency : CAN system clock frequency in Hz, which is no=
rmally
>>>> + =A0 =A0 =A0 half of the oscillator clock frequency. If not speci=
fied, a
>>>> + =A0 =A0 =A0 default value of 8000000 (8 MHz) is used.
>>> A clock-frequency property typically refers to the bus clock
>>> frequency. =A0Something like can-frequency would be better.
>>
>> Ah, right, but I'm also not happy with "can-frequency". The manual
>> speaks about the "internal clock", which is half of the external
>> oscillator frequency. Maybe "internal-clock-frequency" might be bett=
er.

Would it be better to specify the external clock frequency, and the
driver know that internal freq is half that?  I ask because external
clock freq is a value the HW designer actually has control over.

>>>> +- cdr-reg : value of the SJA1000 clock divider register according=
 to
>>>> + =A0 =A0 =A0 the SJA1000 data sheet. If not specified, a default =
value of
>>>> + =A0 =A0 =A0 0x48 is used.
>>> Ewh. =A0The driver should be clueful enough to derive the clock div=
ider
>>> value given both the bus and can frequencies. =A0I don't like this
>>> property.
>>
>> The clock divider register controls the CLKOUT frequency for the
>> microcontroller another CAN controller and allows to deactivate the
>> CLKOUT pin. It's not used to configure the CAN bus frequency.
>>
>>>> +- ocr-reg : value of the SJA1000 output control register accordin=
g to
>>>> + =A0 =A0 =A0 the SJA1000 data sheet. If not specified, a default =
value of
>>>> + =A0 =A0 =A0 0x0a is used.
>>> Ditto here; the binding should describe the usage mode; not the
>>> register settings to get the usage mode. =A0What sort of settings w=
ill
>>> the .dts author be writing here?
>>
>> Unfortunately, there are many:
>>
>> clkout-frequency
>> bypass-comperator
>> tx1-output-on-rx-irq
>>
>> #define OCR_MODE_BIPHASE =A00x00
>> #define OCR_MODE_TEST =A0 =A0 0x01
>> #define OCR_MODE_NORMAL =A0 0x02
>> #define OCR_MODE_CLOCK =A0 =A00x03
>>
>> #define OCR_TX0_INVERT =A0 =A00x04
>> #define OCR_TX0_PULLDOWN =A00x08
>> #define OCR_TX0_PULLUP =A0 =A00x10
>> #define OCR_TX0_PUSHPULL =A00x18
>> #define OCR_TX1_INVERT =A0 =A00x20
>> #define OCR_TX1_PULLDOWN =A00x40
>> #define OCR_TX1_PULLUP =A0 =A00x80
>> #define OCR_TX1_PUSHPULL =A00xc0
>>
>> I think implementing properties for each option is overkill.

Ugh, I see what you mean.

> Would the following more descriptive properties be OK?
>
> =A0clock-out-frequency =3D <0>, // CLKOUT pin clock off
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D <4000000>; // frequenc=
y on CLKOUT pin

Or how about CLKOUT pin off if the property isn't present?  Otherwise,
this looks okay.  BTW, I'd consider prefixing this with 'nxp,' or
'sja1000,' to protect the namespace.  clock-out-frequency sounds like
one of those names which could be commonly used in the future.  I'd so
the same for the other chip-specific properties too.

Segher, what's your opinion on this?

> =A0bypass-input-comparator; // allows to bypass the CAN input compara=
tor.
>
> =A0tx1-output-on-rx-irq; =A0 =A0// allows the TX1 output to be used a=
s a
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 // dedicated RX i=
nterrupt output.
>
> =A0output-control-mode =3D <0x0> // bi-phase output mode
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<0x1> // test output m=
ode
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<0x2> // normal output=
 mode (default)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<0x3> // clock output =
mode
>
> =A0output-pin-config =3D <0x01> // TX0 invert
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<0x02> // TX0 pull-down
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<0x04> // TX0 pull-up
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<0x06> // TX0 push-pull
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<0x08> // TX1 invert
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<0x10> // TX1 pull-down
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<0x20> // TX1 pull-up
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<0x30> // TX1 push-pull

hmmm; It is very chip specific and it is a lot of mucking around.  If
you prefix the property with the manufacturer name, then perhaps the
explicit register setting is okay.

Are TX0 & TX1 protocol pins or GPIOs?  If gpio, then maybe it is worth
the mucking about to then use the gpios binding to specify the pin
mode.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.

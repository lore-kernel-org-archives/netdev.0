From: David Daney <david.daney@cavium.com>
Subject: Re: [PATCH v2 2/3] netdev/of/phy: Add MDIO bus multiplexer support.
Date: Wed, 28 Sep 2011 10:42:09 -0700
Message-ID: <4E835C71.1010108@cavium.com>
References: <1317166015-20714-1-git-send-email-david.daney@cavium.com> <1317166015-20714-3-git-send-email-david.daney@cavium.com> <CAHXqBFLzrkH4AJVozbtT4k7ccgVgfaPoq69J48DeSJKSwEtxHw@mail.gmail.com> <4E8350A8.7090307@cavium.com> <CAHXqBF+ZVbCGEvnCcOtHk+sOWFLp1CuEnGLq+GEtHQTpu9PuYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHXqBF+ZVbCGEvnCcOtHk+sOWFLp1CuEnGLq+GEtHQTpu9PuYg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/28/2011 10:32 AM, Micha=B3 Miros=B3aw wrote:
> W dniu 28 wrze=B6nia 2011 18:51 u=BFytkownik David Daney
> <david.daney@cavium.com>  napisa=B3:
>> On 09/28/2011 12:25 AM, Micha=B3 Miros=B3aw wrote:
>>>
>>> 2011/9/28 David Daney<david.daney@cavium.com>:
>>> [...]
>>>>
>>>> +Example :
>>>> +
>>>> +       /* The parent MDIO bus. */
>>>> +       smi1: mdio@1180000001900 {
>>>> +               compatible =3D "cavium,octeon-3860-mdio";
>>>> +               #address-cells =3D<1>;
>>>> +               #size-cells =3D<0>;
>>>> +               reg =3D<0x11800 0x00001900 0x0 0x40>;
>>>> +       };
>>>> +
>>>> +       /*
>>>> +          An NXP sn74cbtlv3253 dual 1-of-4 switch controlled by a
>>>> +          pair of GPIO lines.  Child busses 2 and 3 populated wit=
h 4
>>>> +          PHYs each.
>>>> +        */
>>>> +       mdio-mux {
>>>> +               compatible =3D "cavium,mdio-mux-sn74cbtlv3253",
>>>> "cavium,mdio-mux";
>>>> +               gpios =3D<&gpio1 3 0>,<&gpio1 4 0>;
>>>> +               mdio-parent-bus =3D<&smi1>;
>>>> +               #address-cells =3D<1>;
>>>> +               #size-cells =3D<0>;
>>>
>>> This should probably have 'compatible =3D "nxp,sn74cbtlv3253";' her=
e.
>>>
>>
>> No, the sn74cbtlv3253 is a general purpose part that could be used t=
o
>> multiplex anything (I2C, SPI, random analog signals, etc.).  Only wh=
en it is
>> in the "cavium,mdio-mux-sn74cbtlv3253" configuration is it an MDIO b=
us
>> multiplexer.
>
> This should use some generic name then. 'mdio-mux-gpio' or something.
> There's no point in introducing chip's model for a gate-like discrete
> device.

That could be.  We could define an "mdio-mux-gpio" as something that=20
selects the child bus based on the binary encoded value presented on th=
e=20
GPIO lines.

I will regenerate the patch set with this in mind.  Note that the only=20
part of this patch that will change is this mdio-mux.txt file, no actua=
l=20
code is affected.  In patch 3/3 I will add "mdio-mux-gpio" to the=20
=2Eof_match_table.

Thanks,
David Daney

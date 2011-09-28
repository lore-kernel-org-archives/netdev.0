From: David Daney <david.daney@cavium.com>
Subject: Re: [PATCH v2 2/3] netdev/of/phy: Add MDIO bus multiplexer support.
Date: Wed, 28 Sep 2011 09:51:52 -0700
Message-ID: <4E8350A8.7090307@cavium.com>
References: <1317166015-20714-1-git-send-email-david.daney@cavium.com> <1317166015-20714-3-git-send-email-david.daney@cavium.com> <CAHXqBFLzrkH4AJVozbtT4k7ccgVgfaPoq69J48DeSJKSwEtxHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHXqBFLzrkH4AJVozbtT4k7ccgVgfaPoq69J48DeSJKSwEtxHw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/28/2011 12:25 AM, Micha=C5=82 Miros=C5=82aw wrote:
> 2011/9/28 David Daney<david.daney@cavium.com>:
> [...]
>> +Example :
>> +
>> +       /* The parent MDIO bus. */
>> +       smi1: mdio@1180000001900 {
>> +               compatible =3D "cavium,octeon-3860-mdio";
>> +               #address-cells =3D<1>;
>> +               #size-cells =3D<0>;
>> +               reg =3D<0x11800 0x00001900 0x0 0x40>;
>> +       };
>> +
>> +       /*
>> +          An NXP sn74cbtlv3253 dual 1-of-4 switch controlled by a
>> +          pair of GPIO lines.  Child busses 2 and 3 populated with =
4
>> +          PHYs each.
>> +        */
>> +       mdio-mux {
>> +               compatible =3D "cavium,mdio-mux-sn74cbtlv3253", "cav=
ium,mdio-mux";
>> +               gpios =3D<&gpio1 3 0>,<&gpio1 4 0>;
>> +               mdio-parent-bus =3D<&smi1>;
>> +               #address-cells =3D<1>;
>> +               #size-cells =3D<0>;
>
> This should probably have 'compatible =3D "nxp,sn74cbtlv3253";' here.
>

No, the sn74cbtlv3253 is a general purpose part that could be used to=20
multiplex anything (I2C, SPI, random analog signals, etc.).  Only when=20
it is in the "cavium,mdio-mux-sn74cbtlv3253" configuration is it an MDI=
O=20
bus multiplexer.

David Daney.

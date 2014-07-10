From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 1/2] ARM: at91/dt: describe rgmii ethernet phy
 connected to sama5d3xek boards
Date: Thu, 10 Jul 2014 08:35:15 -0700
Message-ID: <CAGVrzcZD1SqwX1KqaMpZmBjOWGuvTSVaye0fkFXW_=h-N_d7WA@mail.gmail.com>
References: <1403777615-25685-1-git-send-email-boris.brezillon@free-electrons.com>
 <1403777615-25685-2-git-send-email-boris.brezillon@free-electrons.com>
 <CAGVrzcbYAEMsU1SFSH761H0isQ4z1M++KK_GLf0OAbGS48YUmw@mail.gmail.com>
 <53AC7BFD.2070806@free-electrons.com> <53AD22D8.2090301@atmel.com> <20140710110720.03f437eb@bbrezillon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Andrew Victor <linux@maxim.org.za>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Shen, Voice" <Voice.Shen@atmel.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Boris BREZILLON <boris.brezillon@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140710110720.03f437eb@bbrezillon>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-07-10 2:07 GMT-07:00 Boris BREZILLON <boris.brezillon@free-electrons.com>:
> On Fri, 27 Jun 2014 09:52:56 +0200
> Nicolas Ferre <nicolas.ferre@atmel.com> wrote:
>
>> On 26/06/2014 22:01, Boris BREZILLON :
>> > Hi Florian,
>> >
>> > On 26/06/2014 20:15, Florian Fainelli wrote:
>> >> Hi Boris,
>> >>
>> >> 2014-06-26 3:13 GMT-07:00 Boris BREZILLON <boris.brezillon@free-electrons.com>:
>> >>> Add ethernet-phy node and specify phy interrupt (connected to pin PB25).
>> >>>
>> >>> The PHY address is not specified here because atmel have 2 different
>> >>> designs
>> >>> for its CPU modules: one is connecting PHYAD[0-2] pins to pull up resistors
>> >>> (Embest design) and the other one is connection PHYAD0 to a pull up
>> >>> resistor and PHYAD[1-2] to pull down resistors (Ronetix design).
>> >>> As a result, Ronetix design will have its PHY available at address 0x1 and
>> >>> Embest design at 0x7.
>> >>> Let the net PHY core automatically detect the PHY address by scanning the
>> >>> MDIO bus.
>> >> I though the compatible string was listed as a required property, but
>> >> it is not. The 'reg' property however is listed as required, although
>> >> the of_miodbus_register() works just fine without it, although that is
>> >> a Linux-specific implementation detail.
>> >
>> > Indeed, it's listed in the required property list of the DT binding doc,
>> > but the code implement auto detection if reg is missing.
>> > However this line [1] clearly shows that specifying the reg property is
>> > the preferred way of doing things.
>> >
>> > I could define 2 different sama5d3xcm.dtsi (sama5d3xcm-ronetix.dtsi and
>> > sama5d3xcm-embest.dtsi) to avoid this dirty hack,
>> > but then we would have 2 more dtb and the user would have to determine
>> > which CPU module he owns to choose the appropriate dtb.
>> > If at91, arm-soc and DT maintainers agree with this approach I can
>> > definitely propose something.
>>
>> Yes Boris, I definitively prefer not to add another .dtsi file for this
>> series if we can avoid it.
>>
>
> Okay, now that I don't specify the reg property I have a bunch of
> noisy logs (which is exactly what the developer of of_mdio.c wanted in
> order to force people to specify the reg property).
>
> It seems to be a problem for atmel users (all these logs make them
> think there is something wrong with the net device).
>
> Apart from the dts/dtsi split solution, which Nicolas wants to avoid, I
> see two solutions here:
>
> 1) remove the logs (or use dev_dbg instead of dev_info) from of_mdio.c.
> But I'm pretty sure this solution won't be accepted :-).

I am fine with using dev_dbg() instead of dev_info() for that sort of
messages, provided that you state the rationale of this change
(spewing the log console with probing messages) and specify tha the
'reg' property is optional.

>
> 2) define 2 ethernet phys (one for each possible solution). I tested it
> and it works fine (only the available PHY is registered and there is no
> noisy logs anymore).

One advantage of that solution is that you'll get slightly faster boot
times since you won't have to auto-probe for the PHYs on the MDIO bus,
the time savings get bigger as you start using higher PHY addresses.

>
> Could net and DT maintainers help us choose the best solution (or
> propose a new one) ?
>
> Best Regards,
>
> Boris
>
> --
> Boris Brezillon, Free Electrons
> Embedded Linux and Kernel engineering
> http://free-electrons.com



-- 
Florian

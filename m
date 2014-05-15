From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCHv3 3/4] of: provide a binding for fixed link PHYs
Date: Thu, 15 May 2014 09:54:32 -0700
Message-ID: <CAGVrzcZ1h_Cm=b2aKEAcXYJyVOhoRZLcpXFh0oBB-wodMJnB8Q@mail.gmail.com>
References: <20140308055033.BE0F2C405B0@trevor.secretlab.ca> <20140515153957.75a8aa2a@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Lior Amsalem <alior@marvell.com>,
	Mark Rutland <mark.rutland@arm.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:43424 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbaEOQzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 12:55:14 -0400
In-Reply-To: <20140515153957.75a8aa2a@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

2014-05-15 6:39 GMT-07:00 Thomas Petazzoni
<thomas.petazzoni@free-electrons.com>:
> Dear Grant Likely,
>
> Sorry for bringing back this old topic, but I'm working on this again,
> hopefully reaching an acceptable solution this time. One question for
> you below.
>
> On Sat, 08 Mar 2014 05:50:33 +0000, Grant Likely wrote:
>
>> > +Example:
>> > +
>> > +ethernet@0 {
>> > +   ...
>> > +   phy = <&phy0>;
>> > +   phy0: phy@0 {
>> > +         fixed-link;
>> > +         speed = <1000>;
>> > +         full-duplex;
>> > +   };
>>
>> The phy phandle to a child node is superfluous. A phandle to a fixed
>> child node doesn't make a whole lot of sense.
>
> [...]
>
>> There should be no address portion in the node name. It isn't a child
>> device, the node is merely more configuration data for the parent.
>>
>> Example:
>>
>> ethernet@0 {
>>       ...
>>       fixed-link {
>>             speed = <1000>;
>>             full-duplex;
>>       };
>
> For my current use case, I'm personally fine with that. But that
> doesn't work well with Florian Fainelli's which to potentially have the
> "fixed-link" node as part of another node in the DT, in the case the
> PHY is configurable through some separate SPI/I2C bus. See his comment
> in http://article.gmane.org/gmane.linux.network/306789:

I just re-read Grant's comments, and I don't think we contradict with
each other here. Since the data-path is symetrical by nature, whether
you place the 'fixed-link' property on one end (Ethernet MAC) or the
other (SPI/I2C/GPIO node) does make a huge difference, except you want
it to be placed where it makes the most sense: in the Ethernet MAC
node. Properties like the speed, duplex, pause are definitively
Ethernet MAC only properties.

In case we need to specifically associate these two nodes with each
other, a phandle property to the Ethernet MAC node, or e.g: the SPI
node can be used.

That said, I think we should go with Grant's proposal of having the
following representation:

ethernet@0 {
      ...
       fixed-link {
             speed = <1000>;
             full-duplex;
       };

we might want to use 'max-speed' instead of speed, but that's debatable.

>
> """
> Another problem with that "old" 'fixed-link' property is that we are
> not properly capturing and representing Ethernet switches/PHYs whose
> data-path are isolated from the control path. For instance such
> devices will traditionally expose their control path as a
> MMIO/GPIO/I2C/SPI interface. Using the 5-digit 'fixed-link' property
> we are not representing this, on one side the Ethernet MAC is just
> told to hardcode the link parameters with some parameters, and on
> other side, any MMIO/GPIO/I2C/SPI device is not equipped with the
> correct properties to express the fact that is also has a data-path
> connected to an Ethernet MAC.
>
> What I like about this new binding is that we could place the
> 'fixed-link' related properties in e.g: a SPI slave node, and have the
> Ethernet MAC be pointed at it by a phandle to tell it: look this is
> your PHY, it might not be one you could address on a MDIO bus, so I
> have been providing additional properties to help you with the link
> configuration.
> """
>
> What is your opinion about this?
>
> Thanks,
>
> Thomas
> --
> Thomas Petazzoni, CTO, Free Electrons
> Embedded Linux, Kernel and Android engineering
> http://free-electrons.com
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel



-- 
Florian

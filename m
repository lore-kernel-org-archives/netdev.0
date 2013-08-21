From: Christian Gmeiner <christian.gmeiner@gmail.com>
Subject: Re: [RFC PATCH 1/3] of: provide a binding for the 'fixed-link' property
Date: Wed, 21 Aug 2013 12:55:52 +0200
Message-ID: <CAH9NwWewcDE57g8qgy4aeOeQpfE_RA8hT+cQ9U2_gOFEWKAUDQ@mail.gmail.com>
References: <1373902450-11857-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1373902450-11857-2-git-send-email-thomas.petazzoni@free-electrons.com>
 <20130812063806.GD2324@pengutronix.de> <20130812101649.743c08aa@skate> <20130812083746.GM26614@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Rob Herring <rob.herring@calxeda.com>,
	Florian Fainelli <florian@openwrt.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:50031 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452Ab3HUK4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 06:56:13 -0400
Received: by mail-qa0-f54.google.com with SMTP id bv4so319520qab.6
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 03:56:12 -0700 (PDT)
In-Reply-To: <20130812083746.GM26614@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--
Christian Gmeiner, MSc


2013/8/12 Sascha Hauer <s.hauer@pengutronix.de>:
> On Mon, Aug 12, 2013 at 10:16:49AM +0200, Thomas Petazzoni wrote:
>> Dear Sascha Hauer,
>>
>> On Mon, 12 Aug 2013 08:38:06 +0200, Sascha Hauer wrote:
>>
>> > > This patch adds:
>> > >
>> > >  * A documentation for the Device Tree property "fixed-link".
>> > >
>> > >  * A of_phy_register_fixed_link() OF helper, which provided an OF node
>> > >    that contains a "fixed-link" property, registers the corresponding
>> > >    fixed PHY.
>> > >
>> > >  * Removes the warning on the of_phy_connect_fixed_link() that says
>> > >    new drivers should not use it, since Grant Likely indicated that
>> > >    this "fixed-link" property is indeed the way to go.
>> > >
>> >
>> > Any progress with this series?
>>
>> I am not sure there really was a consensus yet on what the DT binding
>> looks like. As soon as there is a consensus, I'm definitely willing to
>> make progress on this series.
>>
>> > We have more and more boards here with exactly the same problem as
>> > Thomas has. For reasons stated below I don't like this binding, but
>> > still it would solve my problem.
>>
>> Ok.
>>
>> > > +Example:
>> > > +
>> > > +ethernet@0 {
>> > > + ...
>> > > + fixed-link = <1 1 1000 0 0>;
>> > > + ...
>> > > +};
>> >
>> > I must say I don't like this binding at all for two reasons.
>>
>> As I explained, this binding was chosen for this RFC for two reasons:
>>
>>  * It's the binding used on PowerPC platforms to represent fixed links.
>>  * It allows to encode all the informations into a single property,
>>    which avoids the need for a separate DT node for a "fake PHY", which
>>    isn't a representation of the hardware.
>
> The fake phy is avoided by making the other side of the link what it
> really is: An ethernet switch. I'm currently not aware of a situation
> where a fixed link is needed and the other side is not a switch. And I
> can't think of a situation in which the other side of the other side of
> the fixed link really is pure 'virtual', I mean there always must be
> something connected, right?
>
>>
>> > First the positional arguments make it impossible to add optional
>> > arguments to the link.
>> >
>> > Second the other side of the link is most likely a switch. Once this
>> > switch has its own node in the devicetree it seems like having a phandle
>> > to the switch here would be better.
>>
>> So, in other words, what you're suggesting is something like:
>>
>>       ethernet@0 {
>>               reg = <...>;
>>               interrupt = <...>;
>>               phy = <&phy0>;
>>               phy0: phy@0 {
>>                       fixed-link;
>>                       speed = <1000>;
>>                       full-duplex;
>>                       ...
>>               };
>>       };
>
> Yes, this looks good. ePAPR suggests naming the phy property
> "phy-handle" instead of just "phy", but that's just details. In case the
> phy really is a switch the phandle could just point to a i2c device instead
> of the ethernet node.
>

I have here a I.MX6 based board where I have the same issue that the
MAC is directly
connected to a switch. The switch has 5 phys (5 port 100mbt switch)
but the phy5 is not
physically connected to my FEC MAC as my hw guy has chosen to do it without it.
In general it is not a bad idea and I got networking working in u-boot
quite easily.

http://patchwork.ozlabs.org/patch/266558/

Now I am interested in a solution and I think that a fixed-phy is the wrong way.
I like the fixed-link solution more as it models the real world
better. In my example I
do not have any phy, but I have a fixed-link.

&fec {
        pinctrl-names = "default";
        pinctrl-0 = <&pinctrl_enet_1>;
        fixed-link = <0 1 100 0 0>;
        status = "okay";
};

--
Christian Gmeiner, MSc

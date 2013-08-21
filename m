From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH 1/3] of: provide a binding for the 'fixed-link' property
Date: Wed, 21 Aug 2013 12:46:46 +0100
Message-ID: <CAGVrzcY4yY9YafYhewGtAKCwGgzi_KEhSaHQj4v+SsS3QY8ANg@mail.gmail.com>
References: <1373902450-11857-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1373902450-11857-2-git-send-email-thomas.petazzoni@free-electrons.com>
 <20130812063806.GD2324@pengutronix.de> <20130812101649.743c08aa@skate> <20130812083746.GM26614@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lior Amsalem <alior@marvell.com>,
	netdev <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:40059 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700Ab3HULr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 07:47:27 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so749940pad.14
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 04:47:26 -0700 (PDT)
In-Reply-To: <20130812083746.GM26614@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
> where a fixed link is needed and the other side is not a switch.

There is such hardware out there, some platforms have a MoCA PHY which
is responsible for the signaling/control path while the data-path can
be connected to a slightly modified Ethernet MAC.

> And I
> can't think of a situation in which the other side of the other side of
> the fixed link really is pure 'virtual', I mean there always must be
> something connected, right?

I agree, there is something on the other end in every case.

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

I do like this representation better than the existing fixed-link property.
--
Florian

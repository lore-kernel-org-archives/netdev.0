From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: Fixed PHY Device Tree usage?
Date: Wed, 10 Jul 2013 18:39:51 +0200
Message-ID: <20130710183951.09a0bcea@skate>
References: <20130709183312.6c4d052d@skate>
	<CAGVrzcZ7ZLSDy5sTUR_XuSAUH=5q8ddiXx5n1y680WwGrdFfTw@mail.gmail.com>
	<1733937.SiPWt3mDlH@lenovo>
	<20130710182216.0dcfaaaf@skate>
	<CAGVrzcbt302tTM3pprnhJz7YykUzcW=XSMCr_W=m1zWiVBX8kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory =?UTF-8?B?Q2zDqW1lbnQ=?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>, grant.likely@secretlab.ca,
	afleming@freescale.com
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:41673 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754056Ab3GJQj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 12:39:57 -0400
In-Reply-To: <CAGVrzcbt302tTM3pprnhJz7YykUzcW=XSMCr_W=m1zWiVBX8kw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Florian Fainelli,

On Wed, 10 Jul 2013 17:29:44 +0100, Florian Fainelli wrote:

> > Should we have something like:
> >
> >         mdio-fixed {
> >                 compatible = "generic,mdio-fixed";
> >                 phy0: ethernet-phy@0 {
> >                         ... all the properties you listed ...
> >                         ... maybe the "id" property is not needed
> >                             because of the phandle ...
> 
> In the "fixed-phy" terminology "id" is unfortunately ambiguous, the
> driver internally uses "phy_id" which is nothing more than a PHY
> address, but it also supports being assigned an "id" as in
> Identification register 2 & 3. I was refering to the identification
> register by "id".

Hum, but your "id" property contained a string, so I'm not sure how it
would fit in Identification register 2 and 3. Am I missing something
obvious here? Maybe you wanted to have:

	id = <0xdeadbeef>;

which would make the "emulated" PHY return 0xdeadbeef as its PHY ID
when reading those identification registers.

> >                 };
> >
> >                 phy1: ethernet-phy@1 {
> >                         ... all the properties you listed ...
> >                         ... maybe the "id" property is not needed
> >                             because of the phandle ...
> >                 };
> >         };
> >
> >         soc {
> >                 ethernet@0 {
> >                         phy = <&phy0>;
> >                         ...
> >                 };
> >
> >                 ethernet@1 {
> >                         phy = <&phy1>;
> >                         ...
> >                 };
> >         };
> >
> > or do you have in mind another representation?
> 
> Not really this is more or less what I had in mind. I am wondering
> whether we should really declare the "mdio-fixed" node, or if we
> should not rather make the following:
> 
> - declare all PHY nodes in the system as sub nodes of their belonging
> real hardware MDIO bus node
> - flag specific PHY nodes as "fixed" with a "fixed-link" boolean for instance
> - if we see that flag, make that specific PHY node bind to the
> fixed-phy driver instead

So the fixed PHY driver is going to travel through *all* nodes of the
DT, and whenever some random node has a "fixed" property, it's going to
say it corresponds to a fixed PHY? That doesn't seem like a good idea.

So that's really what I was asking: how is the fixed PHY driver going
to know which DT nodes to look at. Is it a platform_driver, where the
corresponding DT node has sub-nodes? Is it something else? Or a
specific compatible string?

> What do you think? I suspect someone might rightfully say that the
> "fixed-mdio" is not a real piece of hardware and is just a software
> concept. A PHY in the real world may very well have a fixed link
> speed/duplex/pause settings on the other end.

I agree that the mdio-fixed idea is clearly moving away from the
hardware representation. But see my question above: we need a way of
letting the fixed PHY driver know which DT nodes it should have a look
at. And just saying "those nodes will have property 'foo' is not
sufficient".

Best regards,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com

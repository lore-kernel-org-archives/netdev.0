From: Florian Fainelli <florian@openwrt.org>
Subject: Re: Fixed PHY Device Tree usage?
Date: Wed, 10 Jul 2013 17:29:44 +0100
Message-ID: <CAGVrzcbt302tTM3pprnhJz7YykUzcW=XSMCr_W=m1zWiVBX8kw@mail.gmail.com>
References: <20130709183312.6c4d052d@skate> <CAGVrzcZ7ZLSDy5sTUR_XuSAUH=5q8ddiXx5n1y680WwGrdFfTw@mail.gmail.com>
 <1733937.SiPWt3mDlH@lenovo> <20130710182216.0dcfaaaf@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	=?UTF-8?Q?Gregory_Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>, grant.likely@secretlab.ca,
	afleming@freescale.com
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:63625 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736Ab3GJQaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 12:30:25 -0400
Received: by mail-pd0-f180.google.com with SMTP id 10so6461496pdi.39
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 09:30:24 -0700 (PDT)
In-Reply-To: <20130710182216.0dcfaaaf@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas,

2013/7/10 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>:

[snip]

>> >
>> > It has the same properties as the binding described in:
>> > Documentation/devicetree/bindings/net/fsl-tsec-phy.txt but expressed in a
>> > more explicit way instead of using an array of integers.
>
> And so the fixed-phy driver would look for what exactly in the Device
> Tree to find which fixed PHYs to create?
>
> Should we have something like:
>
>         mdio-fixed {
>                 compatible = "generic,mdio-fixed";
>                 phy0: ethernet-phy@0 {
>                         ... all the properties you listed ...
>                         ... maybe the "id" property is not needed
>                             because of the phandle ...

In the "fixed-phy" terminology "id" is unfortunately ambiguous, the
driver internally uses "phy_id" which is nothing more than a PHY
address, but it also supports being assigned an "id" as in
Identification register 2 & 3. I was refering to the identification
register by "id".

>                 };
>
>                 phy1: ethernet-phy@1 {
>                         ... all the properties you listed ...
>                         ... maybe the "id" property is not needed
>                             because of the phandle ...
>                 };
>         };
>
>         soc {
>                 ethernet@0 {
>                         phy = <&phy0>;
>                         ...
>                 };
>
>                 ethernet@1 {
>                         phy = <&phy1>;
>                         ...
>                 };
>         };
>
> or do you have in mind another representation?

Not really this is more or less what I had in mind. I am wondering
whether we should really declare the "mdio-fixed" node, or if we
should not rather make the following:

- declare all PHY nodes in the system as sub nodes of their belonging
real hardware MDIO bus node
- flag specific PHY nodes as "fixed" with a "fixed-link" boolean for instance
- if we see that flag, make that specific PHY node bind to the
fixed-phy driver instead

What do you think? I suspect someone might rightfully say that the
"fixed-mdio" is not a real piece of hardware and is just a software
concept. A PHY in the real world may very well have a fixed link
speed/duplex/pause settings on the other end.
--
Florian

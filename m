From: Florian Fainelli <florian@openwrt.org>
Subject: Re: Fixed PHY Device Tree usage?
Date: Tue, 9 Jul 2013 17:44:55 +0100
Message-ID: <CAGVrzcZ7ZLSDy5sTUR_XuSAUH=5q8ddiXx5n1y680WwGrdFfTw@mail.gmail.com>
References: <20130709183312.6c4d052d@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	=?UTF-8?Q?Gregory_Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:39189 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab3GIQpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 12:45:35 -0400
Received: by mail-pd0-f171.google.com with SMTP id y14so5388702pdi.30
        for <netdev@vger.kernel.org>; Tue, 09 Jul 2013 09:45:35 -0700 (PDT)
In-Reply-To: <20130709183312.6c4d052d@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas,

2013/7/9 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>:
> Hello,
>
> We have a case of an hardware platform that uses the mvneta network
> driver, but instead of the SoC being connected to a PHY, it's connected
> directly to a switch, so my understanding is that there's no MDIO bus,
> and we should have a kind of a "fake PHY" to make the mvneta driver
> believe that the link is up, at a given speed.

Good timing, I was about to post questions/suggestions about how we
should represent fixed PHYs in device tree.

>
> Looking at this problem, I stumbled across the "fixed PHY" driver in
> drivers/net/phy/fixed.c, which registers a fake "Fixed MDIO bus", and
> then provides a fixed_phy_add() API to add one "fake" PHY. This seems
> to fit my need, except that my ARM platform is obviously Device Tree
> based, so I'm wondering what I should do. One option is to implement a
> Device Tree binding for the fixed PHY driver (the exact DT binding
> would have to be discussed), but I'm wondering whether describing a
> fixed PHY in the DT is actually correct, because describing a fixed PHy
> is not really describing the hardware, the hardware is actually a
> switch.

Well, it does not seem to be too far from the "hardware" reality to
describe a link between a switch CPU port and an Ethernet MAC as a
fixed PHY because that is what it really is in fact. Once you have a
drivers for your switch you can start using this PHY along with its
corresponding driver.

There is a helper: of_phy_connect_fixed_link() in drivers/of/of_mdio.c
is flagged as being a
temporary solution for Freescale Ethernet drivers to move to something else,
so I would like to discuss what the "something else should be".

Here what I would like to see the new "fixed-link" phy node look like:

ethernet-phy@0 {
     reg = <0>;
     id = "deadbeef";
     speed = <1000>;
     full-duplex;
     pause;
     asym-pause;
};

It has the same properties as the binding described in:
Documentation/devicetree/bindings/net/fsl-tsec-phy.txt but expressed in a more
explicit way instead of using an array of integers.

>
> Do you have some thoughts about this situation? Maybe there's already
> some solutions that I'm not aware of?
>
> Thanks,
--
Florian

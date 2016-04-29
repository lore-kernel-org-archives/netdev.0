From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: Re: FWD: [PATCH v2] Marvell phy: add fiber status check for some
 components
Date: Fri, 29 Apr 2016 10:28:01 +0200
Message-ID: <d3b31c38-a15c-bf49-d787-1a7dcd11849d@nexvision.fr>
References: <20160404132552.GH21828@lunn.ch> <570BFF50.6060909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 16.mo5.mail-out.ovh.net ([87.98.174.144]:37375 "EHLO
	16.mo5.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbcD2Joe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 05:44:34 -0400
Received: from player788.ha.ovh.net (gw6.ovh.net [213.251.189.206])
	by mo5.mail-out.ovh.net (Postfix) with ESMTP id 7E5F0100C80F
	for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 10:28:03 +0200 (CEST)
In-Reply-To: <570BFF50.6060909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/04/2016 =C3=A0 21:47, Florian Fainelli a =C3=A9crit :
>> Do we actually need to stay on page 1 if fibre is in use? How do we
>> initially change to page 1 when the fibre link is still down?
>=20
> I also do not feel very comfortable with reading the fiber status fir=
st,
> and then copper and then combine these two. At the very best, could w=
e
> do something like:
>=20
> - identify if the PHY is configured for fiber in drv->probe or
> drv->config_init, retain that information

But, how configure in runtime the user choice? Add a driver option?
Else, a default choice should be added in init/probe function and the u=
ser should change by ethtool or driver recompilation.

> - have two paths in drv->read_status which take care of reading one
> status or the other?

I worked for a solution around that.
But the Marvell's datasheet seems to agree with my previous method:

Extract:
"Notes on Determining which Media Linked Up

Since there are two sets of IEEE registers (one for copper and the othe=
r for fiber) the software needs
to be aware of register 22.7:0 so that the correct set of registers are=
 selected. In general the
sequence is as follows.

1-Set the Auto-Negotiation registers of the copper medium. (This step m=
ay not be necessary if the
hardware configuration defaults are acceptable).

2-Set the Auto-Negotiation registers of the fiber medium. (This step ma=
y not be necessary if the
hardware configuration defaults are acceptable).

3-Poll for link status.Go to step 4 if there is link.

4-Once there is link determine whether the link is copper or fiber medi=
um.

5-Look at the Auto-Negotiation results for the medium that established =
link.

6-Poll for link status. If link status goes down then go back to step 3=
=2E"

By default, the phy is configured to be connected on both interfaces wi=
th any preference. The first connected was selected.
A preference could be added, but it is not a force mode.

Extract:
"Preferred Media

The device can be programmed to give one media priority over the other.=
 In other words if the
non-preferred media establishes link first and subsequently energy is d=
etected on the preferred
media, the PHY will drop link on the non-preferred media for 4 seconds =
and give the preferred media
a chance to establish link."

We don't have registers to know really if Copper or Fiber is selected. =
We can know only by checking status registers as in my commit.


>> Should we be using the old mechanism to swap between TP, BNC and AUI
>> to swap between copper and fibre?
>=20
> Did you mean using ethtool -s <iface> port fibre for instance?

So, to implement that I have to renable the port change in phy_ethtool_=
sset function.
But, the datasheet seems to disagree with this method.

=46inally, what do I have to do? I continue my previous way or your sug=
gestion?
I prefer to respect the datasheet, but if it's better for you to follow=
 the other way, I will implement that.

Thank you in advance and have a nice day.
Regards,
Charles-Antoine Couret

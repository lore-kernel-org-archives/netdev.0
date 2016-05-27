From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: Re: FWD: [PATCH v2] Marvell phy: add fiber status check for some
 components
Date: Fri, 27 May 2016 11:23:22 +0200
Message-ID: <9dd03fd9-1241-fc7d-ead3-feb7e918d4c3@nexvision.fr>
References: <20160404132552.GH21828@lunn.ch> <570BFF50.6060909@gmail.com>
 <d3b31c38-a15c-bf49-d787-1a7dcd11849d@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8.mo178.mail-out.ovh.net ([46.105.74.227]:52577 "EHLO
	8.mo178.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbcE0Kim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2016 06:38:42 -0400
Received: from player169.ha.ovh.net (b9.ovh.net [213.186.33.59])
	by mo178.mail-out.ovh.net (Postfix) with ESMTP id A70CCFFC086
	for <netdev@vger.kernel.org>; Fri, 27 May 2016 11:23:24 +0200 (CEST)
In-Reply-To: <d3b31c38-a15c-bf49-d787-1a7dcd11849d@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,
I'm sorry to repost that, but after one month, I need a answer to conti=
nue to imrpove my patch in the right direction. :)

Thank you in advance.
Regards.
Charles-Antoine Couret

Le 29/04/2016 =C3=A0 10:28, Charles-Antoine Couret a =C3=A9crit :
> Le 11/04/2016 =C3=A0 21:47, Florian Fainelli a =C3=A9crit :
>>> Do we actually need to stay on page 1 if fibre is in use? How do we
>>> initially change to page 1 when the fibre link is still down?
>>
>> I also do not feel very comfortable with reading the fiber status fi=
rst,
>> and then copper and then combine these two. At the very best, could =
we
>> do something like:
>>
>> - identify if the PHY is configured for fiber in drv->probe or
>> drv->config_init, retain that information
>=20
> But, how configure in runtime the user choice? Add a driver option?
> Else, a default choice should be added in init/probe function and the=
 user should change by ethtool or driver recompilation.
>=20
>> - have two paths in drv->read_status which take care of reading one
>> status or the other?
>=20
> I worked for a solution around that.
> But the Marvell's datasheet seems to agree with my previous method:
>=20
> Extract:
> "Notes on Determining which Media Linked Up
>=20
> Since there are two sets of IEEE registers (one for copper and the ot=
her for fiber) the software needs
> to be aware of register 22.7:0 so that the correct set of registers a=
re selected. In general the
> sequence is as follows.
>=20
> 1-Set the Auto-Negotiation registers of the copper medium. (This step=
 may not be necessary if the
> hardware configuration defaults are acceptable).
>=20
> 2-Set the Auto-Negotiation registers of the fiber medium. (This step =
may not be necessary if the
> hardware configuration defaults are acceptable).
>=20
> 3-Poll for link status.Go to step 4 if there is link.
>=20
> 4-Once there is link determine whether the link is copper or fiber me=
dium.
>=20
> 5-Look at the Auto-Negotiation results for the medium that establishe=
d link.
>=20
> 6-Poll for link status. If link status goes down then go back to step=
 3."
>=20
> By default, the phy is configured to be connected on both interfaces =
with any preference. The first connected was selected.
> A preference could be added, but it is not a force mode.
>=20
> Extract:
> "Preferred Media
>=20
> The device can be programmed to give one media priority over the othe=
r. In other words if the
> non-preferred media establishes link first and subsequently energy is=
 detected on the preferred
> media, the PHY will drop link on the non-preferred media for 4 second=
s and give the preferred media
> a chance to establish link."
>=20
> We don't have registers to know really if Copper or Fiber is selected=
=2E We can know only by checking status registers as in my commit.
>=20
>=20
>>> Should we be using the old mechanism to swap between TP, BNC and AU=
I
>>> to swap between copper and fibre?
>>
>> Did you mean using ethtool -s <iface> port fibre for instance?
>=20
> So, to implement that I have to renable the port change in phy_ethtoo=
l_sset function.
> But, the datasheet seems to disagree with this method.
>=20
> Finally, what do I have to do? I continue my previous way or your sug=
gestion?
> I prefer to respect the datasheet, but if it's better for you to foll=
ow the other way, I will implement that.
>=20
> Thank you in advance and have a nice day.
> Regards,
> Charles-Antoine Couret
>=20

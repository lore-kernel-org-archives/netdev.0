From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 4/6] of: add API for changing parameters of fixed link
Date: Fri, 27 Mar 2015 20:31:23 +0300
Message-ID: <551593EB.9060802@list.ru>
References: <55155AFC.4050800@list.ru> <55155D35.1070703@list.ru> <CAGVrzcau0mUne8uXsTs_9=e4JtQt5w5L+hwtLmKo+UfjSEwC+w@mail.gmail.com> <5515803F.3020600@list.ru> <CAGVrzcaLfQcTAx8OR=sE=7FLrp0gGvfX8_YfxK_CU+x26JHymw@mail.gmail.com> <551587D1.5070408@list.ru> <5515904A.1060600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp46.i.mail.ru ([94.100.177.106]:40212 "EHLO smtp46.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753377AbbC0Rfa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 13:35:30 -0400
In-Reply-To: <5515904A.1060600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

27.03.2015 20:15, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 27/03/15 09:39, Stas Sergeev wrote:
>> 27.03.2015 19:21, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>> Do you want mvneta to register a similar callback in of_mdio, inst=
ead
>>>> of adding an explicit state-updating functions? Something like
>>>> of_phy_fixed_link_set_update_callback()?
>>> You don't need an of_phy_fixed_link_set_update callback, you just n=
eed
>>> to provide a fixed_link_update callback in mvneta, that you registe=
r,
>> That approach I in fact considered initially, as the simplest one,
>> and even had a patch. But I disliked the fact that then mvneta will
>> exploit the knowledge of the fact that of_phy_register_fixed_link()
>> uses a fixed_phy driver. What if the implementation will later chang=
e?
>=20
> There is no reason why it should change later, that's the entire purp=
ose
> of why we can tell whether it is a fixed PHY or a regular MDIO-manage=
d
> PHY, and drivers rely on that for their operations.
I don't think anything is exported to the outside of of_mdio.
It uses fixed_phy driver completely internally. Assuming that we
can pass the created phy_device to the fixed_phy API directly, look
like a bit of layering violation to me. But it is not that big as to
worry about. :)
I don't think many drivers rely on that - perhaps only dsa_slave.
So I'll add the second one.

> Ok, you could either make of_phy_register_fixed_link() return a
> phy_device,
OK, if you think that's right - I'll do.
I was under an impression that this was intentional to not return
the phy.

> I think your concerns are valid, but I don't think there is going to =
be
> any problem with the approach I suggested because there is a contract
> that the fixed PHYs and regular PHYs need to
OK, so I'll do that on Monday then.

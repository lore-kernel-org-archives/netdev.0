From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH 2/3] of_mdio: add new DT property 'managed' to specify the
 PHY management type
Date: Tue, 14 Jul 2015 23:26:10 +0300
Message-ID: <55A57062.80703@list.ru>
References: <55A5424D.4030809@list.ru> <55A5432C.1080609@list.ru>
 <55A54C3A.1040403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Grant Likely <grant.likely@linaro.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.mail.ru ([94.100.179.58]:44117 "EHLO smtp3.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752666AbbGNU2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 16:28:51 -0400
In-Reply-To: <55A54C3A.1040403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

14.07.2015 20:51, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 14/07/15 10:13, Stas Sergeev wrote:
>> Currently the PHY management type is selected by the MAC driver arbi=
trary.
>> The decision is based on the presence of the "fixed-link" node and o=
n a
>> will of the driver's authors.
>> This caused a regression recently, when mvneta driver suddenly start=
ed
>> to use the in-band status for auto-negotiation on fixed links.
>> It appears the auto-negotiation may not work when expected by the MA=
C driver.
>> Sebastien Rannou explains:
>> << Yes, I confirm that my HW does not generate an in-band status. AF=
AIK, it's
>> a PHY that aggregates 4xSGMIIs to 1xQSGMII ; the MAC side of the PHY=
 (with
>> inband status) is connected to the switch through QSGMII, and in thi=
s context
>> we are on the media side of the PHY. >>
>> https://lkml.org/lkml/2015/7/10/206
>>
>> This patch introduces the new string property 'managed' that allows
>> the user to set the management type explicitly.
>> The supported values are:
>> "auto" - default. Uses either MDIO or nothing, depending on the pres=
ence
>> of the fixed-link node
>> "mdio" - use MDIO
>> "in-band-status" - use in-band status
>> "none" - use fixed-link description
> I thought we agreed in the last thread that "mdio" was implied whenev=
er
> a proper PHY phandle to a device sitting on MDIO bus is used and that
> "auto" did not make much sense unless we were also describing how to =
do
> this auto-negotiation completely?
Exactly not:
---
> If we would implement autoneg outside of the fixed-link,
> then its semantic would likely be
> autoneg =3D "mdio" | "in-band" | "off"

Right, if auto-negotiation was defined outside of fixed-link, that is
indeed how I would also specify this.
---

That's why I implemented it the way you see.
But as you changed your mind, I'll remove "mdio".

> As mentioned below, "mdio" is redundant with finding a "phy-handle",=20
> and "auto" is not specific enough to be useful to a consumer of this=20
> information.=20
I prefer to keep "auto", as otherwise we'll have the default
value (when the option is not specified) never achievable
when the option _is_ specified, which is probably not very
good. But I can remove "none" instead, leaving only
"in-band-status" and "auto". Ok?
Of course one can propose to completely ignore that option
in presence of MDIO, but I wonder why not to allow for
example to opt for in-band status even if you have MDIO?
So if we want this option to play nicely with MDIO, as opposed
to being entirely overridden, then "auto" still makes sense IMO.

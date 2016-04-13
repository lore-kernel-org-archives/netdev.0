From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: Re: FWD: [PATCH v2] Marvell phy: add fiber status check for some
 components
Date: Wed, 13 Apr 2016 11:27:21 +0200
Message-ID: <570E10F9.6060107@nexvision.fr>
References: <20160404132552.GH21828@lunn.ch> <570BFF50.6060909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2.mo6.mail-out.ovh.net ([46.105.76.65]:58244 "EHLO
	2.mo6.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934296AbcDMNm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 09:42:28 -0400
Received: from mail188.ha.ovh.net (gw6.ovh.net [213.251.189.206])
	by mo6.mail-out.ovh.net (Postfix) with SMTP id 9F4A6FF9F46
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 11:27:29 +0200 (CEST)
In-Reply-To: <570BFF50.6060909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/04/2016 21:47, Florian Fainelli a =C3=A9crit :
> On 04/04/16 06:25, Andrew Lunn wrote:
>>> >From 564b767163d19355a3b5efaad195e93796570c71 Mon Sep 17 00:00:00 =
2001
>>> From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
>>> Date: Fri, 1 Apr 2016 16:16:35 +0200
>>> Subject: [PATCH] Marvell phy: add fiber status check for some compo=
nents
>>>
>>> Marvell's phy could have two modes: fiber and copper. Currently, th=
e driver
>>> checks only the copper mode registers to get the status link which =
could be
>>> wrong.
>>>
>>> This commit add a handler to check fiber then copper status link.
>>> If the fiber link is activated, the driver would use this informati=
on.
>>> Else, it would use the copper status.
>>
>> Hi Florian
>>
>> What do you think about this?
>>
>> This works for basic status information. But what about other ethtoo=
l
>> options? Setting the speed and duplex, turning pause on/off, etc.
>=20
> Agreed, it seems like a PHY configured for fiber will need to provide
> these informations differently, or does the standard BMSR register
> provide accurate information already?


The BSMR is similar between fiber and copper mode (but, it's the same v=
alues for duplex, speed...) in register 17.
To force speed, duplex, etc. it's the same way too (register 0).

The register's numbers are the same, only the page change.

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
> - have two paths in drv->read_status which take care of reading one
> status or the other?

It should be a great idea.
Because, we could select the preferred link (copper or fiber). This opt=
ion could select that during the init process.

I could save the state into marvell_priv structure, but how configure t=
his choice ? Set copper by default and the user change that
by ethtool, driver loading option or the driver code ? I don't know wha=
t is the correct way to configure that properly.=20


> Are there other side effects for other register accesses (say,
> statistics, or auto-negotiation) that need to be fiber vs. copper awa=
re?

Auto-negociation are separated. But the statistics are globally common,=
 there are some specific registers about that too. But I think these re=
gisters are not relevant.

I will improve my patch.
Thanks.

Regards.
Charles-Antoine Couret

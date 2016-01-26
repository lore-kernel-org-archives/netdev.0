From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [BISECTED] v4.5-rc1 phylib regression
Date: Tue, 26 Jan 2016 15:54:13 -0800
Message-ID: <56A80725.1070808@gmail.com>
References: <20160126044624.GH3880@lunn.ch> <20160126121435.GK22974@ak-desktop.emea.nsn-net.net> <20160126133417.GI3880@lunn.ch> <CAOesGMgaB8R+7jGyLNgQ-M+2nVRhOsEp7LUbiApEEw+dscfL0w@mail.gmail.com> <20160126175353.GG27473@lunn.ch> <CAOesGMhYU4NOeGRJoF4bcELCFfSsvBVp2du7ZgVjC3QuCv637w@mail.gmail.com> <CAOesGMi+ymn_FdDfgTjwgyO-MsEJNGBDU9ayRJvGkjJ7T_ExfA@mail.gmail.com> <56A7DB27.6080203@gmail.com> <20160126213600.GJ27473@lunn.ch> <CAOesGMiEzhN9sGBTq57xnti_Fy1J4rO=djehNHwj47ZhetymXw@mail.gmail.com> <20160126220924.GK27473@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Aaro Koskinen <aaro.koskinen@nokia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36364 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbcAZXzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2016 18:55:06 -0500
In-Reply-To: <20160126220924.GK27473@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/01/16 14:09, Andrew Lunn wrote:
>>> Nope, not an option. Only a small number of DTB actually use c22 or
>>> c45. The majority of devices have no compatible at all. Why should
>>> they, the binding documentation says it is optional!
>>
>> So one thing that can be done is to just have a whitelist in the
>> driver that we add the known phy compatibles to, with a nice comment
>> above that this should only be for legacy device trees.
> 
> So you mean drivers/of/of_mdio.c:of_mdiobus_child_is_phy()
> has a white list like:
> 
> "brcm,40nm-ephy"
> "marvell,88E1111", 
> "marvell,88e1116",
> "marvell,88e1118",
> "marvell,88e1149r",
> "marvell,88e1310",
> "marvell,88E1510",
> "marvell,88E1514",
> "moxa,moxart-rtl8201cp",
> 
> Yes, that would work.
> 
> We should also update the binding documentation to limit what is legal
> in the compatible string.

Agreed, and while at it, take the opportunity to make the compatible
string clause 22/45 mandatory properties so we do not multiply the
whitelist.

Thanks!
-- 
Florian

From: Shaohui Xie <shaohui.xie@nxp.com>
Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
Date: Fri, 22 Jan 2016 10:05:04 +0000
Message-ID: <VI1PR04MB1664AD70D26C452F5A33595AE8C40@VI1PR04MB1664.eurprd04.prod.outlook.com>
References: <1452759839-9874-1-git-send-email-shh.xie@gmail.com>
 <20160114164418.GD19773@lunn.ch>
 <VI1PR04MB166491DEBB439EB72742201DE8CD0@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <56997951.90304@gmail.com> <5699B211.5070602@gmail.com>
 <VI1PR04MB16645A2F24DB515D86136BE2E8C00@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <569C9CD2.10301@gmail.com>
 <VI1PR04MB1664AB0E483F01F1641059FFE8C00@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <20160118151500.GD923@lunn.ch>
 <VI1PR04MB1664DFBC53F08C5CE7EBF22AE8C10@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <20160121211250.GK9991@lunn.ch>
 <VI1PR04MB1664BAFB4EE494CB14830BCCE8C40@VI1PR04MB1664.eurprd04.prod.outlook.com>,<56A1F5AB.6090606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"shh.xie@gmail.com" <shh.xie@gmail.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Shaohui Xie <Shaohui.Xie@freescale.com>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0069.outbound.protection.outlook.com ([157.56.112.69]:38912
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750978AbcAVKFI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 05:05:08 -0500
In-Reply-To: <56A1F5AB.6090606@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Looking at fsl_backplane_config_aneg() you expect phydev->speed to be
>> set, and from the speed you then kick of either KR autoneg or KX
>> autoneg. Could you also start the training at this point? Use the
>> speed to indicate if training is needed?
>
>   [S.H]The training cannot be started at this point, yet, because it's based on
> autoneg result, only when both sides autoneg-ed to 10G-KR, then to start
> the training.

Shaohui,

look, we want you to convince us why to have a generic backplane
property in the phy binding. You had a bad start by adding new
property values to a property that does not relate to your use
case at all. Your job now really is to give strong reasons _why_
and _what_ a phy driver needs to know about the backplane setup.

[S.H] The PHY driver needs to know what the backplane mode is, 
1000BASE-KX or 10GBASE-KR, the driver parses the property for
"1000base-kx" or "10gbase-kr", the driver does use the property,
I don't understand why the property is not related to my use case?

Your first approach was to add "10gbase-rk" or "40gbase-foo" but
now you tell us about ANEG. Of what use is the information given
by the property when ANEG tells you something different? E.g.
consider the property tells you "10g-something" but ANEG gives
you "40g"; does the property add any value to your training
decision now?

[S.H] The ANEG is not a gerneric AN, it's special to 10G-KR,  KR AN can only
AN to KR if both sides support KR, it cannot give "40g" or anything different, 
drive needs the property to do speicific init.

> Besides the driver, generally speaking, "copper + speed" is not enough to indicate
> it's backplane, for ex. "copper + 1000" does not mean it has to be 1000BASE-KX,
> it could be SGMII, hence cannot use KX autoneg.

So, is it copper + speed + backplane? or speed + backplane? And out of
the set of required input, is there anything your _cannot_ determine
from other things, e.g. ANEG?

[S.H] Backplane is enough, 1000BASE-KX means : copper + 1000 + KX stuff.
The KR AN is to check whether LP is also KR, if yes, do training, otherwise, do nothing.

If it is backplane only, would a boolean property ("backplane-mode")
be enough for the training decision?

[S.H] a boolean property is not enough, there are different backplane modes.

> If putting backplane property to phy.txt is not good, I can put it to fsl specific
> binding, like the second patch 2/3 did.

You seem to see vendor specific properties as a place to dump all your
waste you don't want to think about. You fail to give good reasons what
is so special about the backplane setup and now you are telling us that
it is even fsl-specific?

[S.H] I don't think it's waste, I just thought it might be special to fsl.
Agreed I failed to give good reasons, but I tried hard to. :(

Thanks,
Shaohui

Sebastian

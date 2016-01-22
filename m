From: Shaohui Xie <shaohui.xie-3arQi8VN3Tc@public.gmane.org>
Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
Date: Fri, 22 Jan 2016 14:09:52 +0000
Message-ID: <VI1PR04MB1664B669925ADB21D3A13594E8C40@VI1PR04MB1664.eurprd04.prod.outlook.com>
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
 <VI1PR04MB1664BAFB4EE494CB14830BCCE8C40@VI1PR04MB1664.eurprd04.prod.outlook.com>,<56A1F5AB.6090606@gmail.com>,<VI1PR04MB1664AD70D26C452F5A33595AE8C40@VI1PR04MB1664.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <VI1PR04MB1664AD70D26C452F5A33595AE8C40-mr6QIVyDiCHTAO9RNConP89NdZoXdze2vxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I'm not sure I explained myself clearly in previous reply, so I guess it's worth to
rephrase it.

1000BASE-KX and 10GBASE-KR are backplane modes supported by Freescale's PCS
PHY, but different modes need different hardware settings, not just different PHY init
routines, this also needs different serdes lane settings, this is done in probe() according
to DTS properties.

Regarding the autoneg part, it's not like normal autoneg which can autoneg to different
capabilities, when the PHY is 1000BSE-KX, it can only autoneg to 1000BASE-KX only if
LP is 1000BASE-KX,  same is true for 10GBASE-KR. The purpose of KR AN is to detect whether
LP is also KR, if yes, do training, if not, do nothing, no any other result the KR AN can give.

The reason "copper + speed" is not enough for backplane is because they are not precise,
and backplane itself explains what it is, for ex. 1000BASE-KX clearly means the media is copper,
speed is 1000, and should follow 1000BASE-KX standard in IEEE802.3.

The reason I mentioned maybe I should put the backplane property in fsl's binding is because
the backplane implementation is really vendor specific, it's heavily relay how hardware implements
the feature, maybe another vendor's hardware only needs a boolean property for driver to tell it 
should work in backplane, hardware can deal with different modes, or even no any special 
property needed if the hardware is strong enough to handle any connections, I cannot assume.
But I know what fsl's hardware needs to support backplane.

Thank you for your time and reviewing!
Shaohui

________________________________________
From: Shaohui Xie
Sent: Friday, January 22, 2016 6:05 PM
To: Sebastian Hesselbarth; Andrew Lunn
Cc: Florian Fainelli; shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Shaohui Xie
Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR

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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

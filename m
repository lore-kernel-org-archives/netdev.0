From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
Date: Mon, 18 Jan 2016 09:05:38 +0100
Message-ID: <569C9CD2.10301@gmail.com>
References: <1452759839-9874-1-git-send-email-shh.xie@gmail.com>
 <20160114164418.GD19773@lunn.ch>
 <VI1PR04MB166491DEBB439EB72742201DE8CD0@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <56997951.90304@gmail.com> <5699B211.5070602@gmail.com>
 <VI1PR04MB16645A2F24DB515D86136BE2E8C00@VI1PR04MB1664.eurprd04.prod.outlook.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Shaohui Xie <Shaohui.Xie@freescale.com>
To: Shaohui Xie <shaohui.xie@nxp.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"shh.xie@gmail.com" <shh.xie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36233 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbcARIFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 03:05:43 -0500
In-Reply-To: <VI1PR04MB16645A2F24DB515D86136BE2E8C00@VI1PR04MB1664.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.01.2016 08:23, Shaohui Xie wrote:
>>> If you look at the list of possible values for "phy-mode" you'd see
>>> that none of it describes a PHY-to-PHY connection but all are for
>>> MAC-to-PHY connections. Also, names above suggest it already: MII is
>>> short for media _independent_ interface.
>>>
>>> I copy Andrew's concerns and think that neither 10000base-kx nor
>>> 10gbase-kr belong in the list of phy-mode properties.
>>
>> I concur with that as well, if the phy connection does not really matter here,
>> or does not seem like a good fit, maybe we should have a different property, or
>> just define the hardware interface a little differently?
> Right, 'phy-mode' is not a good fit for backplanes, how about a new property like
> 'backplane-mode' or something, like below:

Hmm. We already have a speed property for that you can use for
1000, 10000, 40000. Leaves the media-type, e.g. copper or whatever.

Currently, you fail to convince me that it is required to describe
the media type at all. We have come a long way with different media
without describing the PHY-to-PHY media type.

What makes the backplane setup so special?

Sebastian

>
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -33,6 +33,9 @@ Optional Properties:
>   - broken-turn-around: If set, indicates the PHY device does not correctly
>     release the turn around line low at the end of a MDIO transaction.
>
> +- backplane-mode: string, operation mode of the backplane PHY;
> +  must be "1000base-kx" for 1000BASE-KX, or "10gbase-kr" for 10GBASE-KR.
> +
>   Example:
>
>   ethernet-phy@0 {
>
> Thank you!
>
> Shaohui
>

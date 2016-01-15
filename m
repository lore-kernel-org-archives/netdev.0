From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
Date: Fri, 15 Jan 2016 23:57:21 +0100
Message-ID: <56997951.90304@gmail.com>
References: <1452759839-9874-1-git-send-email-shh.xie@gmail.com>
 <20160114164418.GD19773@lunn.ch>
 <VI1PR04MB166491DEBB439EB72742201DE8CD0@VI1PR04MB1664.eurprd04.prod.outlook.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Shaohui Xie <Shaohui.Xie@freescale.com>
To: Shaohui Xie <shaohui.xie@nxp.com>, Andrew Lunn <andrew@lunn.ch>,
	"shh.xie@gmail.com" <shh.xie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35461 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbcAOW50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 17:57:26 -0500
In-Reply-To: <VI1PR04MB166491DEBB439EB72742201DE8CD0@VI1PR04MB1664.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.01.2016 05:01, Shaohui Xie wrote:
>> -----Original Message-----
>> From: Andrew Lunn [mailto:andrew@lunn.ch]
>> Sent: Friday, January 15, 2016 12:44 AM
>> To: shh.xie@gmail.com
>> Cc: devicetree@vger.kernel.org; netdev@vger.kernel.org; linuxppc-
>> dev@lists.ozlabs.org; f.fainelli@gmail.com; davem@davemloft.net; Shaohui Xie
>> Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
>>
>> On Thu, Jan 14, 2016 at 04:23:59PM +0800, shh.xie@gmail.com wrote:
>>> From: Shaohui Xie <Shaohui.Xie@freescale.com>
>>>
>>> This commit adds necessary definitions for the PHY layer to recognize
>>> backplane Ethernet 1000BASE-KX and 10GBASE-KR as valid PHY interfaces,
>>> "1000base-kx" for 1000BASE-KX, "10gbase-kr" for 10GBASE-KR.
>>>
>>> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
>>> ---
>>> changes in v2:
>>> new patch.

Shaohui,

it would be more useful to describe _what_ is new here compared to v1.

Anyway:

>>>  Documentation/devicetree/bindings/net/ethernet.txt | 4 ++--
>>>  include/linux/phy.h                                | 6 ++++++
>>>  2 files changed, 8 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/ethernet.txt
>>> b/Documentation/devicetree/bindings/net/ethernet.txt
>>> index 5d88f37..1166a5c 100644
>>> --- a/Documentation/devicetree/bindings/net/ethernet.txt
>>> +++ b/Documentation/devicetree/bindings/net/ethernet.txt
>>> @@ -11,8 +11,8 @@ The following properties are common to the Ethernet
>> controllers:
>>>    the maximum frame size (there's contradiction in ePAPR).
>>>  - phy-mode: string, operation mode of the PHY interface; supported values are
>>>    "mii", "gmii", "sgmii", "qsgmii", "tbi", "rev-mii", "rmii",
>>> "rgmii", "rgmii-id",
>>> -  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii"; this is now a
>>> de-facto
>>> -  standard property;
>>> +  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii", "1000base-kx",
>>> + "10gbase-kr";  this is now a de-facto standard property;
>>
>> I know very little about this, so i'm just asking a question. None of the other
>> interface modes contain a bit rate. So is the bit rate needed for your two new
>> modes?
> 
> 1000BASE-KX and 10GBASE-KR are terms in IEEE802.3, so as XGMII and GMII. 
> There are interfaces could be different bit rates but same types, 
> e.g. 100BASE-LX10 and 1000BASE-LX10, or 40GBASE-KR4 and 100GBASE-KR4, 
> having bit rate is clear to represent hardware.
> 

If you look at the list of possible values for "phy-mode" you'd see that
none of it describes a PHY-to-PHY connection but all are for MAC-to-PHY
connections. Also, names above suggest it already: MII is short for
media _independent_ interface.

I copy Andrew's concerns and think that neither 10000base-kx nor
10gbase-kr belong in the list of phy-mode properties.

Sebastian

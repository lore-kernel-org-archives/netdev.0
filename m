From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: create drivers/net/mdio and move mdio drivers into it
Date: Wed, 22 Feb 2017 05:38:49 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15A81861@cnshjmbx02>
References: <8729016553E3654398EA69218DA29EEF15A7E753@cnshjmbx02>
 <afdb9ff7-afa9-47b0-0e84-396080fe0867@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A807CA@cnshjmbx02>
 <dfde5fbd-e4de-7b6d-37a6-dba1720cc3d9@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A80800@cnshjmbx02>
 <119144e3-d42e-e4dd-d95d-624e4816cbe3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cugyly@163.com" <cugyly@163.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:43425 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750890AbdBVFjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 00:39:01 -0500
In-Reply-To: <119144e3-d42e-e4dd-d95d-624e4816cbe3@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

1. 
Let's go back to original topic,
Can we move all mdio dirvers into drivers/net/mdio ?
Last time you said half convinced.
If you insist not do it, l will follow your decision.

2.
Per may understanding, 
I don't know why create a struct mii_bus instance to represent a mdio device in current mdio driver.
Why not create a struct mdio_device instance, it's easy to understand.
(We can move part of member of mii_bus to mdio_device).

Then in mdio layer, there will mdio_device and mdio_driver.

Other module(dsa) base on mdio should not register mdio_driver directly.


thanks

> -----Original Message-----
> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> Sent: Tuesday, February 21, 2017 6:31 AM
> To: YUAN Linyu; David S . Miller; Andrew Lunn
> Cc: netdev@vger.kernel.org; cugyly@163.com
> Subject: Re: create drivers/net/mdio and move mdio drivers into it
> 
> 
> 
> On 02/19/2017 10:29 PM, YUAN Linyu wrote:
> >
> >
> >> -----Original Message-----
> >> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> >> Sent: Monday, February 20, 2017 1:42 PM
> >> To: YUAN Linyu; David S . Miller; Andrew Lunn
> >> Cc: netdev@vger.kernel.org; cugyly@163.com
> >> Subject: Re: create drivers/net/mdio and move mdio drivers into it
> >>> 4. support mdio auto probe phy device.
> >>
> >> That's already the case, even in a Device Tree enabled system if you
> >> omit to provide a "reg" property for child nodes, the bus is
> >> automatically scanned.
> >>
> > I check of_mdiobus_registe() which not do auto scan.
> > Which function should I refer?
> 
> of_mdiobus_register() does this:
> 
>         /* Loop over the child nodes and register a phy_device for each
> phy */
>         for_each_available_child_of_node(np, child) {
>                 addr = of_mdio_parse_addr(&mdio->dev, child);
>                 if (addr < 0) {
>                         scanphys = true;
>                         continue;
>                 }
> 
>                 if (of_mdiobus_child_is_phy(child))
>                         of_mdiobus_register_phy(mdio, child, addr);
>                 else
>                         of_mdiobus_register_device(mdio, child, addr);
>         }
> 
>         if (!scanphys)
>                 return 0;
> 
> It does continue with scanning the PHY child nodes which don't have a
> correct "reg" property set here.
> --
> Florian

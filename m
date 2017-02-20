From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: create drivers/net/mdio and move mdio drivers into it
Date: Mon, 20 Feb 2017 14:31:26 -0800
Message-ID: <119144e3-d42e-e4dd-d95d-624e4816cbe3@gmail.com>
References: <8729016553E3654398EA69218DA29EEF15A7E753@cnshjmbx02>
 <afdb9ff7-afa9-47b0-0e84-396080fe0867@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A807CA@cnshjmbx02>
 <dfde5fbd-e4de-7b6d-37a6-dba1720cc3d9@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A80800@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cugyly@163.com" <cugyly@163.com>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36242 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750827AbdBTWb2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 17:31:28 -0500
Received: by mail-pg0-f66.google.com with SMTP id a123so11936332pgc.3
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 14:31:28 -0800 (PST)
In-Reply-To: <8729016553E3654398EA69218DA29EEF15A80800@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/19/2017 10:29 PM, YUAN Linyu wrote:
> 
> 
>> -----Original Message-----
>> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
>> Sent: Monday, February 20, 2017 1:42 PM
>> To: YUAN Linyu; David S . Miller; Andrew Lunn
>> Cc: netdev@vger.kernel.org; cugyly@163.com
>> Subject: Re: create drivers/net/mdio and move mdio drivers into it
>>> 4. support mdio auto probe phy device.
>>
>> That's already the case, even in a Device Tree enabled system if you
>> omit to provide a "reg" property for child nodes, the bus is
>> automatically scanned.
>>
> I check of_mdiobus_registe() which not do auto scan.
> Which function should I refer?

of_mdiobus_register() does this:

        /* Loop over the child nodes and register a phy_device for each
phy */
        for_each_available_child_of_node(np, child) {
                addr = of_mdio_parse_addr(&mdio->dev, child);
                if (addr < 0) {
                        scanphys = true;
                        continue;
                }

                if (of_mdiobus_child_is_phy(child))
                        of_mdiobus_register_phy(mdio, child, addr);
                else
                        of_mdiobus_register_device(mdio, child, addr);
        }

        if (!scanphys)
                return 0;

It does continue with scanning the PHY child nodes which don't have a
correct "reg" property set here.
-- 
Florian

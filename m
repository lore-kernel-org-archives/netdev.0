From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: create drivers/net/mdio and move mdio drivers into it
Date: Sun, 19 Feb 2017 22:15:49 -0800
Message-ID: <acd54450-a582-87b6-10c9-dfa69e7e0351@gmail.com>
References: <8729016553E3654398EA69218DA29EEF15A7E753@cnshjmbx02>
 <afdb9ff7-afa9-47b0-0e84-396080fe0867@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A807CA@cnshjmbx02>
 <dfde5fbd-e4de-7b6d-37a6-dba1720cc3d9@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A807EA@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cugyly@163.com" <cugyly@163.com>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34243 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750920AbdBTGQ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 01:16:29 -0500
Received: by mail-pg0-f66.google.com with SMTP id s67so1021750pgb.1
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 22:15:54 -0800 (PST)
In-Reply-To: <8729016553E3654398EA69218DA29EEF15A807EA@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/19/2017 10:10 PM, YUAN Linyu wrote:
> 
> 
>> -----Original Message-----
>> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
>> Sent: Monday, February 20, 2017 1:42 PM
>> To: YUAN Linyu; David S . Miller; Andrew Lunn
>> Cc: netdev@vger.kernel.org; cugyly@163.com
>> Subject: Re: create drivers/net/mdio and move mdio drivers into it
>>> 3. another idea is bind mdio device to network device
>>
>> You would have to be more specific about what you want to do here. If
>> the MDIO device is e.g: a switch, what we recommend doing is provide a
>> fixed-link node that describes how the Ethernet MAC and the switch's
>> CPU/management ports are connected (that way the MAC always "sees" the
>> link as UP, running with a specific speed and duplex).
>>
> Yes, some system will configured the phy to fixed speed/duplex at boot time,
> no phy driver used in kernel at all.

There is always a PHY driver used, either is a dedicated one, or its the
generic PHY driver in drivers/net/phy/phy_device.c, even when fixed
PHYs/link are used.

> If network device know mdio device it used, we can do phy dump through this 
> mdio device driver.

We are not going to accept MDIO device drivers whose only purpose is to
allow PHY devices register dumps. Implement a proper PHY driver for
these devices, if nothing needs to be done, you just need to call into
genphy_* functions, and just override how to do register dumps.

> 
>> If this is a different kind of MDIO device, e.g: an USB/PCIe/SATA PHY,
>> there is no network device associated with those.
>>
> mdio under drivers/net/, it will not cover these devices.
> 

-- 
Florian

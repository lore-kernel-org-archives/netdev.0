From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 0/8] net: dsa: New registration API
Date: Thu, 30 Apr 2015 10:50:53 -0700
Message-ID: <55426B7D.90207@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com> <20150430131216.GC22831@lunn.ch> <55425D5C.1020101@gmail.com> <20150430172726.GF18874@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:35748 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbbD3RvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 13:51:04 -0400
Received: by pdbqd1 with SMTP id qd1so67522477pdb.2
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 10:51:04 -0700 (PDT)
In-Reply-To: <20150430172726.GF18874@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/04/15 10:27, Andrew Lunn wrote:
> On Thu, Apr 30, 2015 at 09:50:36AM -0700, Florian Fainelli wrote:
>> On 30/04/15 06:12, Andrew Lunn wrote:
>>>> Note that there are currenlty no incompatibles changes made to existing Device
>>>> Tree sources, rather, depending on the bus we are probed for, e.g: MDIO
>>>> the dsa,mii-bus and dsa,ethernet phandles and first cell of the  "reg" property
>>>> will become obsolete, everything else remains entirely compatible. 
>>>
>>> Hi Florian
>>>
>>> I'm not sure dsa,mii-bus and dsa,ethernet will become obsolete. At
>>> least they are probably needed for multi switch setups, and the
>>> possible but probably unlikely multi DSA setups.
>>>
>>> You cannot assume that dsa,mii-bus and dsa,ethernet have the same
>>> parent. In a multi switch setup, it could be there is an mdio-mux in
>>> the picture. So all your probe really tells you, is that there is a
>>> switch on this mii bus, but you don't know what ethernet it is hanging
>>> off.
>>
>> Good point.
>>
>>>
>>> The switch could be hanging off multiple ethernets. I'm working on
>>> supporting this for the WRT1900AC, where i use the bond driver on the
>>> host side. So dsa,ethernet is a phandle to a bond interface.
>>
>> Humm, bond is a software constructs,
> 
> I thought about this for a while, and came to the conclusion that it
> is often a software construct, but it can also be a hardware
> construct, when you have two ethernet interfaces connected to a
> switch, all on one PCB. So i added a DT binding for bonding. In the
> case of WRT1900AC, it looks like:
> 
>        bond: bond {
>                compatible = "linux,bond";
>                slaves = < &eth0 >, < &eth1 >;
>        };

It seems to me that what we would want to represent here, is strictly
the two "CPU" MACs mapping to their respective ports of the switch
(assuming they are on different ports, right?).

Then whether they are part of a bond, such that you can utilize the full
Wi-Fi throughput, is left to the user to configure that.

For instance, on the Linksys EA4500 I use for prototyping, there are two
mv643xx_eth instances connected to a LAN-facing 4 ports group, and the
other to the WAN, port 5 of the switch, this is similar to Mathieu's use
case I believe, and whether we want to have a WAN/LAN separation, or
have the two MACs participate in a LAN or WAN bond should be
user-configurable.

By the same token, we could create bridges for ports 0-3 aka LAN
directly from Device Tree ;)

> 
> and then in DSA i have a phandle to this bond interface. This part
> works great, but i've not posted these patches yet, because it does
> not work yet because of some other issue. Maybe when i do post this,
> it will get shot down?

I suppose you could post the patches and we look at this from there?
-- 
Florian

From: Mason <slash.tmp@free.fr>
Subject: Re: Debugging Ethernet issues
Date: Mon, 14 Nov 2016 14:28:28 +0100
Message-ID: <5829BBFC.7040800@free.fr>
References: <5827AD4A.7010908@free.fr> <20161113030919.GA2892@lunn.ch>
 <5828C452.6050808@free.fr> <9d1f28a7-959b-fdde-3403-f6da5f521125@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Zach Brown <zach.brown@ni.com>,
        Shaohui Xie <shaohui.xie@nxp.com>,
        Tim Beale <tim.beale@alliedtelesis.co.nz>,
        Brian Hill <brian@houston-radar.com>,
        Vince Bridgers <vbridgers2013@gmail.com>,
        Balakumaran Kannan <kumaran.4353@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sebastian Frias <sf84@laposte.net>,
        Kirill Kapranov <kapranoff@inbox.ru>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:12835 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752190AbcKNN3N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 08:29:13 -0500
In-Reply-To: <9d1f28a7-959b-fdde-3403-f6da5f521125@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/11/2016 20:55, Florian Fainelli wrote:
> Le 13/11/2016 à 11:51, Mason a écrit :
>> On 13/11/2016 04:09, Andrew Lunn wrote:
>>
>>> Mason wrote:
>>>
>>>> When connected to a Gigabit switch
>>>> 3.4 negotiates a LAN DHCP setup instantly
>>>> 4.7 requires over 5 seconds to do so
>>>
>>> When you run tcpdump on the DHCP server, are you noticing the first
>>> request is missing?
>>>
>>> What can happen is the dhclient gets started immediately and sends out
>>> its first request before auto-negotiation has finished. So this first packet
>>> gets lost. The retransmit after a few seconds is then successful.
>>
>> I will run tcpdump on the server as I run udhcpc on the client
>> for Linux 3.4 vs 4.7
>>
>> Do you know what would make auto-negotiation fail at 100 Mbps
>> on 4.7? (whereas it succeeds on 3.4)
>>
>> (Thinking out loud) If the problem were in auto-negotiation,
>> then if should work if I hard-code speed and duplex using
>> ethtool, right? (IIRC, hard-coding doesn't help.)
> 
> I would start with checking basic things:
> 
> - does your Ethernet driver get a link UP being reported correctly
> (netif_carrier_ok returns 1)?

I don't see any calls to netif_carrier_ok() in the network driver
( drivers/net/ethernet/aurora/nb8800.c )
Maybe it is using some generic infrastructure?

> - if you let the bootloader configure the PHY and utilize the Generic
> PHY driver instead of the Atheros PHY driver, does the problem appear as
> well?

How exactly does one use the generic PHY driver?
Do you mean the following?
Documentation/devicetree/bindings/net/fixed-link.txt

Regards.

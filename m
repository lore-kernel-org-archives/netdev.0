From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Debugging Ethernet issues
Date: Sun, 13 Nov 2016 11:55:15 -0800
Message-ID: <9d1f28a7-959b-fdde-3403-f6da5f521125@gmail.com>
References: <5827AD4A.7010908@free.fr> <20161113030919.GA2892@lunn.ch>
 <5828C452.6050808@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
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
To: Mason <slash.tmp@free.fr>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34854 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934338AbcKMTzT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 14:55:19 -0500
Received: by mail-it0-f66.google.com with SMTP id b123so8483560itb.2
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 11:55:18 -0800 (PST)
In-Reply-To: <5828C452.6050808@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/11/2016 à 11:51, Mason a écrit :
> On 13/11/2016 04:09, Andrew Lunn wrote:
> 
>> Mason wrote:
>>
>>> When connected to a Gigabit switch
>>> 3.4 negotiates a LAN DHCP setup instantly
>>> 4.7 requires over 5 seconds to do so
>>
>> When you run tcpdump on the DHCP server, are you noticing the first
>> request is missing?
>>
>> What can happen is the dhclient gets started immediately and sends out
>> its first request before auto-negotiation has finished. So this first packet
>> gets lost. The retransmit after a few seconds is then successful.
> 
> I will run tcpdump on the server as I run udhcpc on the client
> for Linux 3.4 vs 4.7
> 
> Do you know what would make auto-negotiation fail at 100 Mbps
> on 4.7? (whereas it succeeds on 3.4)
> 
> (Thinking out loud) If the problem were in auto-negotiation,
> then if should work if I hard-code speed and duplex using
> ethtool, right? (IIRC, hard-coding doesn't help.)

I would start with checking basic things:

- does your Ethernet driver get a link UP being reported correctly
(netif_carrier_ok returns 1)?
- if you let the bootloader configure the PHY and utilize the Generic
PHY driver instead of the Atheros PHY driver, does the problem appear as
well?
- what do transmit/receive counters on the Ethernet driver/MAC return?
-- 
Florian

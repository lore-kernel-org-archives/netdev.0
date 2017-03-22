From: Stas Sergeev <stsp@list.ru>
Subject: Re: Problem: net: mvneta: auto-negotiation with disconnected network
 cable
Date: Thu, 23 Mar 2017 01:03:37 +0300
Message-ID: <b7737751-b051-b717-a856-3e11c73dd25d@list.ru>
References: <DB6PR0501MB2712340C8CDC37F3038766AD943C0@DB6PR0501MB2712.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>
To: Maxime Morin <maxime.morin@vitec.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback9.m.smailru.net ([94.100.178.49]:36689 "EHLO
        fallback9.m.smailru.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753906AbdCVWtB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 18:49:01 -0400
Received: from [10.161.25.39] (port=55642 helo=smtp62.i.mail.ru)
        by fallback9.m.smailru.net with esmtp (envelope-from <stsp@list.ru>)
        id 1cqoM8-0001IW-Qu
        for netdev@vger.kernel.org; Thu, 23 Mar 2017 01:03:49 +0300
In-Reply-To: <DB6PR0501MB2712340C8CDC37F3038766AD943C0@DB6PR0501MB2712.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

22.03.2017 16:23, Maxime Morin пишет:
> Hi all,
>
> I work on an embedded platform based on the Marvell Armada 88F6707, that is connected to a Marvell Alaska 88E1512 ethernet transceiver. A defect has appeared recently, and it turns out to be a regression on the network part. There is a complete lost of the network when following these steps:
>      1) boot the board with the network cable disconnected
>      2) run the following commands (or equivalent):
>          ip link set eth0 up
>          ip addr add 10.0.0.80/24 dev eth0
>          ethtool -s eth0 autoneg on #this is the command that really breaks the network
In fact, the problem is that this control is
counter-intuitive. It could instead be

ethtool autoneg [on|off|mdio|inband]

with "on" implying "mdio". In that case you would
never notice the change. Unfortunately there seems
to be no way of passing the autoneg mode, so I fused
"on" to "inband"... So, unless I am mistaken, this clearly
needs a rework. But I have really forgot all the details.

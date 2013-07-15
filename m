From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Tue, 16 Jul 2013 00:02:30 +0100
Message-ID: <CAGVrzcaqyJcKWFGFtYsTY+raDPp1Ce4yZEoXuD=faXUUquRZQQ@mail.gmail.com>
References: <20130704173552.GA23370@1wt.eu> <20130715163408.4064699f@skate>
 <20130715151240.GD6844@1wt.eu> <20130715172321.61e8c237@skate>
 <20130715153049.GE6844@1wt.eu> <20130715173523.4505e8c4@skate>
 <CAGVrzcYvFr8o+v=Ryc1GVA+7qTLGjxEUC3pB6t06YgTsmu0MAw@mail.gmail.com> <20130715214414.1f885ba8@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willy Tarreau <w@1wt.eu>, netdev <netdev@vger.kernel.org>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:50329 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754928Ab3GOXDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 19:03:11 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf11so110291pab.10
        for <netdev@vger.kernel.org>; Mon, 15 Jul 2013 16:03:10 -0700 (PDT)
In-Reply-To: <20130715214414.1f885ba8@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas,

2013/7/15 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>:
> Dear Florian Fainelli,
>
> On Mon, 15 Jul 2013 16:52:44 +0100, Florian Fainelli wrote:
>
>> > I still believe this is not the right fix, but unfortunately, I haven't
>> > had the time to work on what would be the right fix. Hardware PHY
>> > polling has been intentionally disabled, and the driver should work
>> > without, since the PHY polling is done in software by the phylib.
>>
>> You may now be able to use the PHY interrupt bit from your MAC
>> interrupt handler and call phy_mac_interrupt() provided by libphy. I
>> added it specifically to be able to use PHY link interrupts connected
>> to the MAC.
>
> Right, but the MAC feature in question makes the MAC directly talks to
> the PHY to configure it, completely bypassing the entire libphy logic.
> I am not sure how to handle this together with libphy.

Then you might just replace the default libphy with your PHY state
machine and manage it from within the mvneta driver. This is something
less usual but libphy still allows that.
--
Florian

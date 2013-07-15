From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Mon, 15 Jul 2013 16:52:44 +0100
Message-ID: <CAGVrzcYvFr8o+v=Ryc1GVA+7qTLGjxEUC3pB6t06YgTsmu0MAw@mail.gmail.com>
References: <20130704173552.GA23370@1wt.eu> <20130715163408.4064699f@skate>
 <20130715151240.GD6844@1wt.eu> <20130715172321.61e8c237@skate>
 <20130715153049.GE6844@1wt.eu> <20130715173523.4505e8c4@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willy Tarreau <w@1wt.eu>, netdev <netdev@vger.kernel.org>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:47077 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933126Ab3GOPxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 11:53:25 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so10842663pdj.31
        for <netdev@vger.kernel.org>; Mon, 15 Jul 2013 08:53:24 -0700 (PDT)
In-Reply-To: <20130715173523.4505e8c4@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Thomas, Willy,

2013/7/15 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>:
> Dear Willy Tarreau,
>
> On Mon, 15 Jul 2013 17:30:49 +0200, Willy Tarreau wrote:
>
>> On Mon, Jul 15, 2013 at 05:23:21PM +0200, Thomas Petazzoni wrote:
>> > The big-endian support is pretty light in terms of driver changes, so
>> > if there are conflicts, they should be easy to solve.
>>
>> I agree.
>>
>> BTW, I'm still having the patch to re-enable phy-polling at boot in my
>> queue. Last time I tried without it I still only had eth0 working. I
>> completely forgot about this one. Since I did it blindly, I have no way
>> to verify if what I've done is necessary according to the specs. But I'm
>> quite sure that the NICs that are not enabled by the boot loaders don't
>> work.
>>
>> If you want, I'll resend it to you at the same time.
>
> I still believe this is not the right fix, but unfortunately, I haven't
> had the time to work on what would be the right fix. Hardware PHY
> polling has been intentionally disabled, and the driver should work
> without, since the PHY polling is done in software by the phylib.

You may now be able to use the PHY interrupt bit from your MAC
interrupt handler and call phy_mac_interrupt() provided by libphy. I
added it specifically to be able to use PHY link interrupts connected
to the MAC.
--
Florian

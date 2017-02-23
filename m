From: Paolo Minazzi <paolo.minazzi@gmail.com>
Subject: Re: Software loopback with phy 88E1116R and marvell MV78100 gbe
Date: Thu, 23 Feb 2017 12:28:10 +0100
Message-ID: <CABmfJQZz=8wyTUT4oZrB4zMKbwYSJyyFqPsE+eRVcU-LVz-ibA@mail.gmail.com>
References: <CABmfJQYEqWzPtfieaym-4KhG5f0PBHNDQzuT0Uk_bz-2WC3zag@mail.gmail.com>
 <20170223105958.GC14312@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35146 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750944AbdBWLaE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 06:30:04 -0500
Received: by mail-oi0-f52.google.com with SMTP id 62so15992061oih.2
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 03:28:11 -0800 (PST)
In-Reply-To: <20170223105958.GC14312@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 23, 2017 at 11:59 AM, Andrew Lunn <andrew@lunn.ch> wrote:
>> I tried to do the same things on 88E1116R, setting the but 14 of reg 0.
>> But If I do it I lose the link, and the test program does not work.
>> I tried to force the link in software, but seems the controller send
>> packets but it is not able to receive them.
>> Is possibile to do such a software loopback on 88E1116R ?
>
> Hi Paolo
>
> What you are talking about here is MAC loopback. Packets are looped
> back at the MAC level. The copper side will be left idle, and so the
> link will be lost. This explains why you are seeing link down..

Hi Andrew,
if I understand correctly there are 3 type of loopback.
[1] loopback at the MAC level
[2] loopback at the phy level
[3] loopback with a physical loopback cable

[1] is enabled programming ethernet registers
[2] is enabled programming the PHY
[3] is done at hardware level with a physical loopback cable

> What you might need to do is extend marvell_update_link() to check if
> MAC loopback is happening, and if so, say the link is up.

I agree. For example some driver  (also marvell driver) check the link before
do a TX. If there is not a good link the TX is dropped.
So I have to force link up with a bit in a register (or hacking the
driver) to permit TX.

> But this is all a bit questionable. How are you setting the PHY into
> loopback? I guess the rest of the stack has no idea this is happening,
> in particular the phy state machine. What happens when it comes out of
> loopback? How is autoneg kicked off.

Tried to set the BIT14 of REG0 (LOOPBACK).
Tried also changing BIT12 of REG0 (autoneg anabled and disabled).
Tried to reset the PHY (BIT15 of REG0).
Nothing works,

I have 3 ethernet different card. With 2 of them I can do the software
loopback, both with MAC and PHY loopback.
With marvell gbe I'm not able. There is not MAC loopback (not
documented). There is only PHY loopback.
The physical loopback (with a cable) works correctly.

> You might want to think about the big picture, and how this can be
> incorporated into ethtool, and phylib. MAC loopback is pretty much
> standard, so you should be able to solve this for all PHYs, not just
> Marvell.

It should be,
Paolo

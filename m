From: Jacob Siverskog <jacob@teenage.engineering>
Subject: Re: [PATCH] net: Fix potential NULL pointer dereference in __skb_try_recv_datagram
Date: Wed, 20 Jan 2016 17:17:40 +0100
Message-ID: <CAEnXRPut=4TNjmaw2afepQd5hONJs3xezy_PLrrMXbV-iAKpfg@mail.gmail.com>
References: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
 <87y4cdyrbn.fsf@doppelsaurus.mobileactivedefense.com> <20151229.150843.2021692616139434395.davem@davemloft.net>
 <CAEnXRPtJBoOn+JgXDEUdL07WkbYVViAT_+LBiV4X=NVQ3SiDaQ@mail.gmail.com>
 <CANn89iLpuz4nP+hPoGUHY8KSv=GwSE1x13D3qDeAQDJjV-S7pw@mail.gmail.com>
 <CAEnXRPsVe5ROz=Vo0fTODrs3EsEWoU1hzHVvyEwMyMCrE3BwDA@mail.gmail.com>
 <CAM_iQpVQNPQ1LNvG+h3=UvTM9Lm-adhryQk-ad4aeckHS-V0ew@mail.gmail.com>
 <CAEnXRPsH-eTwwd7FvODL+0Qu9CLY-uGYT9z81cH-by5baEdbhg@mail.gmail.com>
 <1451921108.8255.74.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEnXRPu8As9sr44JcjqVW-omN8BshtzhZZd73cr7vFXLTVPFWQ@mail.gmail.com>
 <1452003299.8255.87.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEnXRPuL6bUJWvJ=OWokHCvZkdcngaYmwX3wV70douDbnG8bVw@mail.gmail.com>
 <1452004797.8255.90.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAEnXRPtPYz4+UTA1dqL7AXe6OeN08tyXhKL2js5Wm681z=tsWQ@mail.gmail.com> <1453304914.1223.325.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Al Viro <viro@zeniv.linux.org.uk>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:36474 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934015AbcATQSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 11:18:00 -0500
Received: by mail-ig0-f173.google.com with SMTP id z14so105129977igp.1
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 08:17:59 -0800 (PST)
In-Reply-To: <1453304914.1223.325.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2016 at 4:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-01-20 at 16:06 +0100, Jacob Siverskog wrote:
>> On Tue, Jan 5, 2016 at 3:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Tue, 2016-01-05 at 15:34 +0100, Jacob Siverskog wrote:
>> >> On Tue, Jan 5, 2016 at 3:14 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >
>> >> >
>> >> > You might build a kernel with KASAN support to get maybe more chances to
>> >> > trigger the bug.
>> >> >
>> >> > ( https://www.kernel.org/doc/Documentation/kasan.txt )
>> >> >
>> >>
>> >> Ah. Doesn't seem to be supported on arm(32) unfortunately.
>> >
>> > Then you could at least use standard debugging features :
>> >
>> > CONFIG_SLAB=y
>> > CONFIG_SLABINFO=y
>> > CONFIG_DEBUG_SLAB=y
>> > CONFIG_DEBUG_SLAB_LEAK=y
>> >
>> > (Or equivalent SLUB options)
>> >
>> > and
>> >
>> > CONFIG_DEBUG_PAGEALLOC=y
>> >
>> > (If arm(32) has CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y)
>>
>> I tried with those enabled and while toggling power on the Bluetooth
>> interface I usually get this after a few iterations:
>> kernel: Bluetooth: Unable to push skb to HCI core(-6)
>
> Well, this code seems to be quite buggy.
>
> I do not have time to audit it, but 5 minutes are enough to spot 2
> issues.
>
> skb, once given to another queue/layer should not be accessed anymore.
>

Ok. Unfortunately I still see the slab corruption even with your changes.

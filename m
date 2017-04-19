From: Code Soldier1 <codesoldier1@gmail.com>
Subject: Re: question about size of sk_buff and skb_shared_info
Date: Tue, 18 Apr 2017 22:20:32 -0700
Message-ID: <CABGNeczts-LsPLVOp_G24b9V-XnZXCKojKtWcN822wAzXunpuw@mail.gmail.com>
References: <CABGNecyP8tpBtbOPL_4fyhqnkTYEa80sHCuDrUJdm9gxihFX6w@mail.gmail.com>
 <1492542021.10587.137.camel@edumazet-glaptop3.roam.corp.google.com>
 <CABGNecz7oRk8PZS_YzG2QzpMXi78rQX4zPpt_28ZgJYYZS-ytg@mail.gmail.com>
 <1492559721.10587.150.camel@edumazet-glaptop3.roam.corp.google.com>
 <CABGNeczXNPkWnhkviHhXv5OpVope_0BGNoB-nsGwALOptrwWdA@mail.gmail.com> <1492562843.10587.153.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36804 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759659AbdDSFUd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 01:20:33 -0400
Received: by mail-io0-f182.google.com with SMTP id o22so14818950iod.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 22:20:33 -0700 (PDT)
In-Reply-To: <1492562843.10587.153.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 5:47 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> For the last time, do not top post on netdev.

Sorry about that.
>
> On Tue, 2017-04-18 at 17:15 -0700, Code Soldier1 wrote:
>> I am not suggesting that we do not do cache alignment. That is
>> required for performance. I have gone through this exercise because I
>> need to add a field to sk_buff and I want to do that without causing
>> any adverse effects.
>>
>> Now that we have discovered that there are 40 bytes that can be used
>> without any adverse effect, may I increase skb->cb by 8 bytes ?
>>
>
> skb->cb is already 48 bytes, not 40.

That is not what I am referring to above. What I am pointing out is
that since skb is not a multiple of cache line size it accesses the
whole cache line but uses only part of the cache line, leaving 40
bytes unused. I would like to use 8 out of those 40 bytes to extend
the size of skb->cb.

>
>> If not then may I increase skb_shared_info -- However that would have
>> to be by 64bytes.
>
>
> You will have a very hard time to convince us that this 8 byte field is
> needed on all skbs, regardless of current sk_buff size.
>

Protocols use as much space as needed and leave the rest for future
use. Since there is no overhead, I don't understand the concern. Can
you please elaborate.

-- 
CS1

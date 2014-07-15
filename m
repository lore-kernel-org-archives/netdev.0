From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH net-next] net-gre-gro: Fix a bug that breaks the
 forwarding path
Date: Tue, 15 Jul 2014 10:17:19 -0700
Message-ID: <CAPshTCgCdJNH6rr-Yri0L8-aDL_kQfWbY9XtwVLxsoHcf-9Ghg@mail.gmail.com>
References: <1405262780-20232-1-git-send-email-hkchu@google.com>
	<CAJZOPZ+wu=6t_AKoKg1KhVJ0=DhczfQ8ekDFKFLEkQv6d=cOfA@mail.gmail.com>
	<CAPshTCjiw8vFK9Y4APwsX5kWnKDByLuOn+1MJa4C08FOevZKQQ@mail.gmail.com>
	<CAJZOPZLwiT7LhxDFYdAq=0iU6heSwBQfCvwxXtoAXMqg=eNAmA@mail.gmail.com>
	<CAPshTCiKnKx_P=JLQcgjS36rWmCtSS43XYNJHeif9Z9yP8C36Q@mail.gmail.com>
	<CAJZOPZJcxb1j+_A2T=yN8bkjBH3CFjnb05q56dxAwtZ4i85Mpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Wolfgang Walter <linux@stwm.de>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:48112 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757181AbaGORRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 13:17:20 -0400
Received: by mail-yh0-f50.google.com with SMTP id v1so1931309yhn.9
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 10:17:19 -0700 (PDT)
In-Reply-To: <CAJZOPZJcxb1j+_A2T=yN8bkjBH3CFjnb05q56dxAwtZ4i85Mpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 7:06 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> On Tue, Jul 15, 2014 at 12:30 AM, Jerry Chu <hkchu@google.com> wrote:
>>
>> On Mon, Jul 14, 2014 at 1:38 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>> > On Mon, Jul 14, 2014 at 10:16 PM, Jerry Chu <hkchu@google.com> wrote:
>> >> On Mon, Jul 14, 2014 at 12:05 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>> >>> On Sun, Jul 13, 2014 at 5:46 PM, H.K. Jerry Chu <hkchu@google.com> wrote:
>> >>>> Fixed a bug that was introduced by my GRE-GRO patch
>> >>>> (bf5a755f5e9186406bbf50f4087100af5bd68e40 net-gre-gro: Add GRE
>> >>>> support to the GRO stack) that breaks the forwarding path
>> >>>> because various GSO related fields were not set. The bug will
>> >>>> cause on the egress path either the GSO code to fail, or a
>> >>>> GRE-TSO capable (NETIF_F_GSO_GRE) NICs to choke. The following
>> >>>> fix has been tested for both cases.
>> >
>> >>> Anything different in this version vs. the one you posted earlier on
>> >>> February or this is a plain re-post?
>> >
>> >> I simply moved the patch against the latest net-next and resolved some small
>> >> conflict so yes it's pretty much the same.
>> >
>> > OK, got it.
>> >
>> >> Also I don't see the subsequent
>> >> discussion on skb->encapsulation affects the validity of this patch so
>> >> i'm resubmitting it. Also the patch has been confirmed to address the problem
>> >> Wolfgang reported last week. Feel free to test against the configuration (VXLAN?)
>> >> you had some question about earlier.
>> >
>> > Well, re-reading that thread, we were not very decisive there... my
>> > comment of setting the inner network header twice in inet_gro_complete
>> > doesn't apply only to vxlan but to other tunneling protocols.
>>
>> Understood, but my reply about it applying to the inner most hdr in the end
>> is not limited to vxlan either.
>>
>> > Also, if
>> > we really need (why do we? or explained it on the Feb thread) to set
>> > skb->encapsulation for the sake of TX in a protocol (GRE) gro
>> > complete, looks a bit fishy to me...
>>
>> Why does it look fishy? When h/w support sLRO on tunneled pkts
>> driver will set that bit. So it seems very reasonable for the GRO stack
>> that supports tunneled pkts to set that bit too.
>
>
> what do you mean by "h/w support sLRO on tunneled pkts" here? as far
> as I understand, the driver should set the bit when they know it's an
> encapsulated
> packet for which the HW offloaded checksum verification.
>
> So my fishiness comment was referring to the fact that we see here
> that the stack
> is setting this bit too sometimes.

There are many other places in the "stack" that will set that bit if you
grep it. I think many of them are there to make GSO work on tunneled pkts.
The code here is no different.

>
>> > but saying this I think brings us
>> > back to that incomplete discussion [1]  sounds as this needs some
>> > plumbering... Still, this way or another I understand a regression was
>> > introduced here and should be fixed.
>
>> Yep. I thought we've made reasonable progress on the skb->encapsualtion
>> even though we can't close all the questions/issues
>
> where/how exactly (or more or less) this progress comes into play, is it
> by the description exchanged in the emails sent over the Feb/Mar thread
> or in Tom's 3.15/16/17 patches?

Davem wanted a more precise definition of skb->encapsulation and I thought
some worthy discussion has happened as part of the thread of the
original patch (even though it left with some more questions but
that's often the case
with complex kernel code, right?)

>
>> (but we have a real bug that needs to be fixed here).
>
> agree...

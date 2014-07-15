From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] net-gre-gro: Fix a bug that breaks the
 forwarding path
Date: Tue, 15 Jul 2014 21:23:07 +0300
Message-ID: <CAJZOPZJ3KHg=gqW17dPTyCJUmdLgMuqzyJ412tW4+_8g48Oxjg@mail.gmail.com>
References: <1405262780-20232-1-git-send-email-hkchu@google.com>
	<CAJZOPZ+wu=6t_AKoKg1KhVJ0=DhczfQ8ekDFKFLEkQv6d=cOfA@mail.gmail.com>
	<CAPshTCjiw8vFK9Y4APwsX5kWnKDByLuOn+1MJa4C08FOevZKQQ@mail.gmail.com>
	<CAJZOPZLwiT7LhxDFYdAq=0iU6heSwBQfCvwxXtoAXMqg=eNAmA@mail.gmail.com>
	<CAPshTCiKnKx_P=JLQcgjS36rWmCtSS43XYNJHeif9Z9yP8C36Q@mail.gmail.com>
	<CAJZOPZJcxb1j+_A2T=yN8bkjBH3CFjnb05q56dxAwtZ4i85Mpw@mail.gmail.com>
	<CAPshTCgCdJNH6rr-Yri0L8-aDL_kQfWbY9XtwVLxsoHcf-9Ghg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Wolfgang Walter <linux@stwm.de>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:40500 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754573AbaGOSXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 14:23:08 -0400
Received: by mail-qc0-f170.google.com with SMTP id c9so5560285qcz.1
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 11:23:07 -0700 (PDT)
In-Reply-To: <CAPshTCgCdJNH6rr-Yri0L8-aDL_kQfWbY9XtwVLxsoHcf-9Ghg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 8:17 PM, Jerry Chu <hkchu@google.com> wrote:
> On Tue, Jul 15, 2014 at 7:06 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:

>> what do you mean by "h/w support sLRO on tunneled pkts" here? as far
>> as I understand, the driver should set the bit when they know it's an
>> encapsulated  packet for which the HW offloaded checksum verification.

can you clarify the sLRO comment?

>> So my fishiness comment was referring to the fact that we see here
>> that the stack is setting this bit too sometimes.

> There are many other places in the "stack" that will set that bit if you
> grep it. I think many of them are there to make GSO work on tunneled pkts.
> The code here is no different.

I am not near the code now, but AFAIK, the "stack" sets it in the TX
path and the driver sets it in the RX path, any deviation you see
there for this convension except for the change introduced by this
patch.

> Davem wanted a more precise definition of skb->encapsulation and I thought
> some worthy discussion has happened as part of the thread of the
> original patch (even though it left with some more questions but
> that's often the case with complex kernel code, right?)


complex as it may be, if the design is valid (e.g doesn't contradict
itself, etc...) it should be subject to proper documentation and
implementation. So in that repspect, I read Dave's comment as saying
-- guys, this isn't the case with that skb encapsulation bit.

For a nearby example, see the documentation of the semantic of the
different checksum values (e.g none/unnecessary/complete/
partial) that the stack and drivers are setting, it wasn't very
clear/percise since maybe kernel 2.4 and only over one of the last
kernel cycles on Dec 2013 this patch made it clear "net: skbuff:
improve comment on checksumming"

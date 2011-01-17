From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net_sched: accurate bytes/packets stats/rates
Date: Mon, 17 Jan 2011 08:09:40 +0800
Message-ID: <AANLkTim14h+6k6nt+UWP5gDcT5NmAGLU_S+wG6VhDn-O@mail.gmail.com>
References: <1295021808.3937.110.camel@edumazet-laptop> <20110114095201.4fc58a45@nehalam>
 <1295028502.3937.116.camel@edumazet-laptop> <20110114110342.4d95ad5b@nehalam> <20110116223540.GA1861@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47069 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736Ab1AQAKM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jan 2011 19:10:12 -0500
Received: by fxm20 with SMTP id 20so5305966fxm.19
        for <netdev@vger.kernel.org>; Sun, 16 Jan 2011 16:10:11 -0800 (PST)
In-Reply-To: <20110116223540.GA1861@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 17, 2011 at 6:35 AM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
> On Fri, Jan 14, 2011 at 11:03:42AM -0800, Stephen Hemminger wrote:
>> From Eric Dumazet <eric.dumazet@gmail.com>
>>
>> In commit 44b8288308ac9d (net_sched: pfifo_head_drop problem), we fi=
xed
>> a problem with pfifo_head drops that incorrectly decreased
>> sch->bstats.bytes and sch->bstats.packets
>>
>> Several qdiscs (CHOKe, SFQ, pfifo_head, ...) are able to drop a
>> previously enqueued packet, and bstats cannot be changed, so
>> bstats/rates are not accurate (over estimated)
>>
>> This patch changes the qdisc_bstats updates to be done at dequeue() =
time
>> instead of enqueue() time. bstats counters no longer account for dro=
pped
>> frames, and rates are more correct, since enqueue() bursts dont have
>> effect on dequeue() rate.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>> CC: Patrick McHardy <kaber@trash.net>
>> CC: Jarek Poplawski <jarkao2@gmail.com>
>> CC: jamal <hadi@cyberus.ca>
> ...
>> --- a/net/sched/sch_drr.c =A0 =A0 2011-01-14 09:19:00.830857886 -080=
0
>> +++ b/net/sched/sch_drr.c =A0 =A0 2011-01-14 09:28:20.398631228 -080=
0
>> @@ -376,7 +376,6 @@ static int drr_enqueue(struct sk_buff *s
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 bstats_update(&cl->bstats, skb);
>
> Why leave leaf classes with different stats?
>

HTB also has the same problem, and I have fixed in my own product, but
the patch was rejected.

http://patchwork.ozlabs.org/patch/6227/

> Jarek P.
>
>> - =A0 =A0 qdisc_bstats_update(sch, skb);
>>
>> =A0 =A0 =A0 sch->q.qlen++;
>> =A0 =A0 =A0 return err;
> ...



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)

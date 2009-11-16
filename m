From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Mon, 16 Nov 2009 16:43:46 +0800
Message-ID: <412e6f7f0911160043n3a84f79ayd382135bea4c5d2d@mail.gmail.com>
References: <4B00FFD8.4040508@gmail.com> <4B010B09.9020101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:36595 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbZKPInk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 03:43:40 -0500
Received: by pzk1 with SMTP id 1so2639026pzk.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 00:43:46 -0800 (PST)
In-Reply-To: <4B010B09.9020101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/11/16 Eric Dumazet <eric.dumazet@gmail.com>:
> Changli Gao a =A8=A6crit :
>> ifb: add multi-queue support.
>>
>> Add multi-queue support, through more than one tasklets. One tasklet=
 per
>> queue always steers on the same CPU, and if the number of the
>> tasklets(queues) is lager than the number of CPUs, more than one
>> tasklets will be assigned to the same CPU.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ----
>
>>
>
> I must say I fail to see how multiple tasklets per cpu can be of any =
use.
>
> And :
>
> +       if (skb_queue_len(&pq->rq) =3D=3D 1)
> +               tasklet_schedule_on(&pq->task, num % num_online_cpus(=
));
>
> Is probably not what you want, because :
>
> A) num_online_cpus() can be expensive to compute,
> B) and you can have such configs :
>
> Three online cpus, CPU0 and CPU4, CPU5
> -> you call tasklet_schedule_on(... , num =3D {0|1|2})
>
> To avoid packets reorder, if your hash function selects an offline cp=
u,
> you must forward the packet to a particular cpu, regardless of cpu cu=
rrently running.
> (even if real device is not multiqueue, its RX interrupts can be hand=
led by any online cpu)
>
> You maybe need to maintain a mapping table with cpu hotplug notifiers=
=2E
>

Yea, a mapping table is needed in any way. But I don't find a suitable
user interface to do that. And I think many people maybe interested in
the two new APIs: tasklet_schedule_on() and tasklet_hi_schedule_on().
Any comment?

--=20
Regards=A3=AC
Changli Gao(xiaosuo@gmail.com)

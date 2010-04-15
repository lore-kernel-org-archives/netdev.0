From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: fix softnet_stat
Date: Thu, 15 Apr 2010 12:01:18 +0800
Message-ID: <u2y412e6f7f1004142101i42284308y6238d99dab47e755@mail.gmail.com>
References: <1271300513-9995-1-git-send-email-xiaosuo@gmail.com>
	<1271302133.16881.1814.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:36492 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196Ab0DOEBk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 00:01:40 -0400
Received: by iwn35 with SMTP id 35so371919iwn.21
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 21:01:39 -0700 (PDT)
In-Reply-To: <1271302133.16881.1814.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 11:28 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>
> I think this was nice, because we can see number of frames received b=
y
> this cpu, before giving them to another cpu.
>
> Maybe we want a new counter ?
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__get_cpu_var(netdev_rx_stat).inpackets++;
>
>
>>
>> =C2=A0 =C2=A0 =C2=A0 rps_lock(queue);
>> =C2=A0 =C2=A0 =C2=A0 if (queue->input_pkt_queue.qlen <=3D netdev_max=
_backlog) {
>> @@ -2366,9 +2365,9 @@ enqueue:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto enqueue;
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> + =C2=A0 =C2=A0 per_cpu(netdev_rx_stat, cpu).dropped++;
>
> This is a bit expensive, and could be a queue->rx_stat.dropped++
> if netdev_rx_stat is moved inside queue structure.
>
>
>> =C2=A0 =C2=A0 =C2=A0 rps_unlock(queue);
>>
>> - =C2=A0 =C2=A0 __get_cpu_var(netdev_rx_stat).dropped++;
>> =C2=A0 =C2=A0 =C2=A0 local_irq_restore(flags);
>>
>> =C2=A0 =C2=A0 =C2=A0 kfree_skb(skb);
>> @@ -3565,7 +3564,7 @@ static int softnet_seq_show(struct seq_file *s=
eq, void *v)
>> =C2=A0 =C2=A0 =C2=A0 struct netif_rx_stats *s =3D v;
>>
>> =C2=A0 =C2=A0 =C2=A0 seq_printf(seq, "%08x %08x %08x %08x %08x %08x =
%08x %08x %08x %08x\n",
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0s->total, s=
->dropped, s->time_squeeze, 0,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0s->total + =
s->dropped, s->dropped, s->time_squeeze, 0,
>
> This is wrong I believe... I prefer to add a new column, s->inpackets=
 ?
>

the first column total should be the number of the packets, which are
processed by this CPU before RPS involved. If RPS is enabled, it
should keep the old meaning. If new statistics data is needed by RPS,
we would add it in another patch.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)

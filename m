From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH RFC] act_cpu: packet distributing
Date: Fri, 16 Jul 2010 07:30:10 +0800
Message-ID: <AANLkTiljdBpQkZAGybwFQtej-_j7sFtD72CTErT9TaOX@mail.gmail.com>
References: <1279077475-2956-1-git-send-email-xiaosuo@gmail.com>
	<1279078875.2444.103.camel@edumazet-laptop> <AANLkTimPmXWyAspJqnya7aM_vDRNzDdJJf2bl7CYrAXN@mail.gmail.com>
	<1279198139.4510.710.camel@bigi> <1279212897.2496.133.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:50259 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933661Ab0GOXad convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 19:30:33 -0400
Received: by vws5 with SMTP id 5so1789112vws.19
        for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 16:30:32 -0700 (PDT)
In-Reply-To: <1279212897.2496.133.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 16, 2010 at 12:54 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 15 juillet 2010 =E0 08:48 -0400, jamal a =E9crit :
>>
>> RCU maybe a little trickier here Eric. Actions could be shared i.e.
>> example, it is possible to have a policer action restricting rates f=
or a
>> group of flows =A0across multiple netdevices etc. Since action stats=
 get
>> written to by different CPUs concurrently. It could be probably done=
 if
>> one was to implement per-cpu stats which get summed-up when user spa=
ce
>> asks.
>
> It's certainly tricky, but is act_cpu useful in its current shape, ba=
sed
> on an infrastructure that had to use a lock because of exact
> rates/accounting ?
>
> I dont understand how distributing packets to different cpus, if goin=
g
> through a central lock can be an improvement. Changli patches are mos=
t
> of the time not documented, and no performance data is provided.
>
The tcf_lock is per-instance, so I should not an issue here if the
corresponding NIC isn't an multiqueue NIC or the instance is
per-rx-queue. I agree
the performance data is necessary and I'll publish it in the formal
patch.

> Even if we solve this locking problem, using percpu variables, act_cp=
u
> hits another problem :
>
> The socket refcount, taken by the 'master' cpu, and released by the
> consumer cpu.
This is why I asked if I can assign sk to skb.

>
> RFS provides sort of a lazy flow-based distribution without central l=
ock
> or cache line ping pongs. Why Changli dont use this, we dont know yet=
=2E
>
The fact is I don't know how to do this. I'll work on this issue later.

Thanks.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)

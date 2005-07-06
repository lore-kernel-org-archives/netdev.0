From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Wed, 06 Jul 2005 03:04:36 +0200
Message-ID: <42CB2E24.6010303@cosmosbay.com>
References: <20050705173411.GK16076@postel.suug.ch> <20050705.142210.14973612.davem@davemloft.net> <20050705213355.GM16076@postel.suug.ch> <20050705.143548.28788459.davem@davemloft.net> <42CB14B2.5090601@cosmosbay.com> <20050705234104.GR16076@postel.suug.ch> <42CB2698.2080904@cosmosbay.com> <20050706005140.GT16076@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050706005140.GT16076@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf a =E9crit :

>>Maybe we can rewrite the whole thing without branches, examining prio f=
rom=20
>>PFIFO_FAST_BANDS-1 down to 0, at least for modern cpu with conditional =
mov=20
>>(cmov)
>=20
>=20
> This would break the whole thing, the qdisc is supposed to try and
> dequeue from the highest priority queue (prio=3D0) first.
>=20
>=20

I still dequeue a packet from the highest priority queue.

But nothing prevents us to look the three queues in the reverse order, if=
 you can avoid the conditional branches.

No memory penalty, since most of time we were looking at the three queues=
 anyway, and the 3 sk_buff_head are in the same cache line.

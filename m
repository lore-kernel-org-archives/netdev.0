From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Wed, 06 Jul 2005 03:09:00 +0200
Message-ID: <42CB2F2C.7050602@cosmosbay.com>
References: <20050705173411.GK16076@postel.suug.ch> <20050705.142210.14973612.davem@davemloft.net> <20050705213355.GM16076@postel.suug.ch> <20050705.143548.28788459.davem@davemloft.net> <42CB14B2.5090601@cosmosbay.com> <20050705234104.GR16076@postel.suug.ch> <42CB2698.2080904@cosmosbay.com> <42CB2B84.50702@cosmosbay.com> <20050706010200.GU16076@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050706010200.GU16076@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf a =E9crit :
> I think you got me wrong, the whole point of this qdisc
> is to prioritize which means that we cannot dequeue from
> prio 1 as long as the queue in prio 0 is not empty.=20

if prio 0 is not empty, then the last

if (!skb_queue_empty(list))
      best =3D list;

will set 'best' to the prio 0 list, and we dequeue the packet on this pri=
o 0 list, not on prio 1 or prio 2.

>=20
> If you have no traffic at all for prio=3D0 and prio=3D1 then
> the best solution is to replace the qdisc on the device
> with a simple fifo.

Yes sure, but I know that already. Unfortunatly I have some trafic on pri=
o=3D1 and prio=3D0 (about 5 %)

Thank you
Eric

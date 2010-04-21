From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious rcu_dereference_check() usage
Date: Wed, 21 Apr 2010 16:26:17 -0700
Message-ID: <m1zl0wl752.fsf@fess.ebiederm.org>
References: <20100419230136.GA16856@linux.vnet.ibm.com>
	<1271726729.2972.13.camel@dhcp231-113.rdu.redhat.com>
	<20100420030452.GB2905@linux.vnet.ibm.com>
	<4BCD646B.1080206@cn.fujitsu.com>
	<1271766716.2972.16.camel@dhcp231-113.rdu.redhat.com>
	<j2ya44ae5cd1004200545q6be4ec82o18ae99d93e8c29c7@mail.gmail.com>
	<20100420135227.GC2628@linux.vnet.ibm.com>
	<t2la44ae5cd1004200838w87256e80v9dcde91342b321db@mail.gmail.com>
	<20100421213543.GO2563@linux.vnet.ibm.com>
	<1271887029.7895.3535.camel@edumazet-laptop>
	<20100421221426.GS2563@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Miles Lane <miles.lane@gmail.com>,
	Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, vgoyal@redhat.com,
	nauman@google.com, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100421221426.GS2563@linux.vnet.ibm.com> (Paul E. McKenney's message of "Wed\, 21 Apr 2010 15\:14\:26 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> writes:

> On Wed, Apr 21, 2010 at 11:57:09PM +0200, Eric Dumazet wrote:
>> Le mercredi 21 avril 2010 =C3=A0 14:35 -0700, Paul E. McKenney a =C3=
=A9crit :
>>=20
>> > > [   33.425087] [ INFO: suspicious rcu_dereference_check() usage.=
 ]
>> > > [   33.425090] -------------------------------------------------=
--
>> > > [   33.425094] net/core/dev.c:1993 invoked rcu_dereference_check=
()
>> > > without protection!
>> > > [   33.425098]
>> > > [   33.425098] other info that might help us debug this:
>> > > [   33.425100]
>> > > [   33.425103]
>> > > [   33.425104] rcu_scheduler_active =3D 1, debug_locks =3D 1
>> > > [   33.425108] 2 locks held by canberra-gtk-pl/4208:
>> > > [   33.425111]  #0:  (sk_lock-AF_INET){+.+.+.}, at:
>> > > [<ffffffff81394ffd>] inet_stream_connect+0x3a/0x24d
>> > > [   33.425125]  #1:  (rcu_read_lock_bh){.+....}, at:
>> > > [<ffffffff8134a809>] dev_queue_xmit+0x14e/0x4b8
>> > > [   33.425137]
>> > > [   33.425138] stack backtrace:
>> > > [   33.425142] Pid: 4208, comm: canberra-gtk-pl Not tainted 2.6.=
34-rc5 #18
>> > > [   33.425146] Call Trace:
>> > > [   33.425154]  [<ffffffff81067fc2>] lockdep_rcu_dereference+0x9=
d/0xa5
>> > > [   33.425161]  [<ffffffff8134a914>] dev_queue_xmit+0x259/0x4b8
>> > > [   33.425167]  [<ffffffff8134a809>] ? dev_queue_xmit+0x14e/0x4b=
8
>> > > [   33.425173]  [<ffffffff81041c52>] ? _local_bh_enable_ip+0xcd/=
0xda
>> > > [   33.425180]  [<ffffffff8135375a>] neigh_resolve_output+0x234/=
0x285
>> > > [   33.425188]  [<ffffffff8136f71f>] ip_finish_output2+0x257/0x2=
8c
>> > > [   33.425193]  [<ffffffff8136f7bc>] ip_finish_output+0x68/0x6a
>> > > [   33.425198]  [<ffffffff813704b3>] T.866+0x52/0x59
>> > > [   33.425203]  [<ffffffff813706fe>] ip_output+0xaa/0xb4
>> > > [   33.425209]  [<ffffffff8136ebb8>] ip_local_out+0x20/0x24
>> > > [   33.425215]  [<ffffffff8136f204>] ip_queue_xmit+0x309/0x368
>> > > [   33.425223]  [<ffffffff810e41e6>] ? __kmalloc_track_caller+0x=
111/0x155
>> > > [   33.425230]  [<ffffffff813831ef>] ? tcp_connect+0x223/0x3d3
>> > > [   33.425236]  [<ffffffff81381971>] tcp_transmit_skb+0x707/0x74=
5
>> > > [   33.425243]  [<ffffffff81383342>] tcp_connect+0x376/0x3d3
>> > > [   33.425250]  [<ffffffff81268ac3>] ? secure_tcp_sequence_numbe=
r+0x55/0x6f
>> > > [   33.425256]  [<ffffffff813872f0>] tcp_v4_connect+0x3df/0x455
>> > > [   33.425263]  [<ffffffff8133cbd9>] ? lock_sock_nested+0xf3/0x1=
02
>> > > [   33.425269]  [<ffffffff81395067>] inet_stream_connect+0xa4/0x=
24d
>> > > [   33.425276]  [<ffffffff8133b418>] sys_connect+0x90/0xd0
>> > > [   33.425283]  [<ffffffff81002b9c>] ? sysret_check+0x27/0x62
>> > > [   33.425289]  [<ffffffff81068922>] ? trace_hardirqs_on_caller+=
0x114/0x13f
>> > > [   33.425296]  [<ffffffff813ced00>] ? trace_hardirqs_on_thunk+0=
x3a/0x3f
>> > > [   33.425303]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0=
x1b
>> >=20
>> > This looks like an rcu_dereference() needs to instead be
>> > rcu_dereference_bh(), but the line numbering in my version of
>> > net/core/dev.c does not match yours.  CCing netdev, hopefully
>> > someone there will know which rcu_dereference() is indicated.
>>=20
>> This is already sorted out in David trees
>
> Very good!!!  ;-)
>
>> > > [   85.939528] [ INFO: suspicious rcu_dereference_check() usage.=
 ]
>> > > [   85.939531] -------------------------------------------------=
--
>> > > [   85.939535] include/net/inet_timewait_sock.h:227 invoked
>> > > rcu_dereference_check() without protection!
>> > > [   85.939539]
>> > > [   85.939540] other info that might help us debug this:
>> > > [   85.939541]
>> > > [   85.939544]
>> > > [   85.939545] rcu_scheduler_active =3D 1, debug_locks =3D 1
>> > > [   85.939549] 2 locks held by gwibber-service/4798:
>> > > [   85.939552]  #0:  (&p->lock){+.+.+.}, at: [<ffffffff811034b2>=
]
>> > > seq_read+0x37/0x381
>> > > [   85.939566]  #1:  (&(&hashinfo->ehash_locks[i])->rlock){+.-..=
=2E},
>> > > at: [<ffffffff81386355>] established_get_next+0xc4/0x132
>> > > [   85.939579]
>> > > [   85.939580] stack backtrace:
>> > > [   85.939585] Pid: 4798, comm: gwibber-service Not tainted 2.6.=
34-rc5 #18
>> > > [   85.939588] Call Trace:
>> > > [   85.939598]  [<ffffffff81067fc2>] lockdep_rcu_dereference+0x9=
d/0xa5
>> > > [   85.939604]  [<ffffffff81385018>] twsk_net+0x4f/0x57
>> > > [   85.939610]  [<ffffffff813862e5>] established_get_next+0x54/0=
x132
>> > > [   85.939615]  [<ffffffff813864c7>] tcp_seq_next+0x5d/0x6a
>> > > [   85.939621]  [<ffffffff81103701>] seq_read+0x286/0x381
>> > > [   85.939627]  [<ffffffff8110347b>] ? seq_read+0x0/0x381
>> > > [   85.939633]  [<ffffffff81133240>] proc_reg_read+0x8d/0xac
>> > > [   85.939640]  [<ffffffff810ea110>] vfs_read+0xa6/0x103
>> > > [   85.939645]  [<ffffffff810ea223>] sys_read+0x45/0x69
>> > > [   85.939652]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0=
x1b
>> >=20
>> > This one appears to be a case of missing rcu_read_lock(), but it i=
s
>> > not clear to me at what level it needs to go.
>> >=20
>> > Eric, any enlightenment on this one and the next one?
>>=20
>> Coming from commit b099ce2602d806deb41caaa578731848995cdb2a
>> >From Eric Biederman (CCed)
>>=20
>> Apparently he added rcu to twsk_net(), but Changelog doesnt mention =
it.
>
> Thank you for chasing this down, Eric Dumazet!
>
> Eric Biederman, any enlightment?

That change to twsk_net probably should have come in
575f4cd5a5b639457747434dbe18d175fa767db4.  The point was to make
twsk_net usable in an rcu context, instead of requiring a lock.=20

Should it become rcu_deference_raw now that we have lockdep support?

commit 575f4cd5a5b639457747434dbe18d175fa767db4
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Thu Dec 3 02:29:08 2009 +0000

    net: Use rcu lookups in inet_twsk_purge.
   =20
    While we are looking up entries to free there is no reason to take
    the lock in inet_twsk_purge.  We have to drop locks and restart
    occassionally anyway so adding a few more in case we get on the
    wrong list because of a timewait move is no big deal.  At the
    same time not taking the lock for long periods of time is much
    more polite to the rest of the users of the hash table.
   =20
    In my test configuration of killing 4k network namespaces
    this change causes 4k back to back runs of inet_twsk_purge on an
    empty hash table to go from roughly 20.7s to 3.3s, and the total
    time to destroy 4k network namespaces goes from roughly 44s to
    3.3s.
   =20
    Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
    Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>



Eric

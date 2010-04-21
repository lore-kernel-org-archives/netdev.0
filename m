From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] RCU: don't turn off lockdep when find suspicious
 rcu_dereference_check() usage
Date: Wed, 21 Apr 2010 15:14:26 -0700
Message-ID: <20100421221426.GS2563@linux.vnet.ibm.com>
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
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Miles Lane <miles.lane@gmail.com>, Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, vgoyal@redhat.com,
	nauman@google.com, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:57925 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756812Ab0DUWOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 18:14:31 -0400
Content-Disposition: inline
In-Reply-To: <1271887029.7895.3535.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 11:57:09PM +0200, Eric Dumazet wrote:
> Le mercredi 21 avril 2010 =E0 14:35 -0700, Paul E. McKenney a =E9crit=
 :
>=20
> > > [   33.425087] [ INFO: suspicious rcu_dereference_check() usage. =
]
> > > [   33.425090] --------------------------------------------------=
-
> > > [   33.425094] net/core/dev.c:1993 invoked rcu_dereference_check(=
)
> > > without protection!
> > > [   33.425098]
> > > [   33.425098] other info that might help us debug this:
> > > [   33.425100]
> > > [   33.425103]
> > > [   33.425104] rcu_scheduler_active =3D 1, debug_locks =3D 1
> > > [   33.425108] 2 locks held by canberra-gtk-pl/4208:
> > > [   33.425111]  #0:  (sk_lock-AF_INET){+.+.+.}, at:
> > > [<ffffffff81394ffd>] inet_stream_connect+0x3a/0x24d
> > > [   33.425125]  #1:  (rcu_read_lock_bh){.+....}, at:
> > > [<ffffffff8134a809>] dev_queue_xmit+0x14e/0x4b8
> > > [   33.425137]
> > > [   33.425138] stack backtrace:
> > > [   33.425142] Pid: 4208, comm: canberra-gtk-pl Not tainted 2.6.3=
4-rc5 #18
> > > [   33.425146] Call Trace:
> > > [   33.425154]  [<ffffffff81067fc2>] lockdep_rcu_dereference+0x9d=
/0xa5
> > > [   33.425161]  [<ffffffff8134a914>] dev_queue_xmit+0x259/0x4b8
> > > [   33.425167]  [<ffffffff8134a809>] ? dev_queue_xmit+0x14e/0x4b8
> > > [   33.425173]  [<ffffffff81041c52>] ? _local_bh_enable_ip+0xcd/0=
xda
> > > [   33.425180]  [<ffffffff8135375a>] neigh_resolve_output+0x234/0=
x285
> > > [   33.425188]  [<ffffffff8136f71f>] ip_finish_output2+0x257/0x28=
c
> > > [   33.425193]  [<ffffffff8136f7bc>] ip_finish_output+0x68/0x6a
> > > [   33.425198]  [<ffffffff813704b3>] T.866+0x52/0x59
> > > [   33.425203]  [<ffffffff813706fe>] ip_output+0xaa/0xb4
> > > [   33.425209]  [<ffffffff8136ebb8>] ip_local_out+0x20/0x24
> > > [   33.425215]  [<ffffffff8136f204>] ip_queue_xmit+0x309/0x368
> > > [   33.425223]  [<ffffffff810e41e6>] ? __kmalloc_track_caller+0x1=
11/0x155
> > > [   33.425230]  [<ffffffff813831ef>] ? tcp_connect+0x223/0x3d3
> > > [   33.425236]  [<ffffffff81381971>] tcp_transmit_skb+0x707/0x745
> > > [   33.425243]  [<ffffffff81383342>] tcp_connect+0x376/0x3d3
> > > [   33.425250]  [<ffffffff81268ac3>] ? secure_tcp_sequence_number=
+0x55/0x6f
> > > [   33.425256]  [<ffffffff813872f0>] tcp_v4_connect+0x3df/0x455
> > > [   33.425263]  [<ffffffff8133cbd9>] ? lock_sock_nested+0xf3/0x10=
2
> > > [   33.425269]  [<ffffffff81395067>] inet_stream_connect+0xa4/0x2=
4d
> > > [   33.425276]  [<ffffffff8133b418>] sys_connect+0x90/0xd0
> > > [   33.425283]  [<ffffffff81002b9c>] ? sysret_check+0x27/0x62
> > > [   33.425289]  [<ffffffff81068922>] ? trace_hardirqs_on_caller+0=
x114/0x13f
> > > [   33.425296]  [<ffffffff813ced00>] ? trace_hardirqs_on_thunk+0x=
3a/0x3f
> > > [   33.425303]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x=
1b
> >=20
> > This looks like an rcu_dereference() needs to instead be
> > rcu_dereference_bh(), but the line numbering in my version of
> > net/core/dev.c does not match yours.  CCing netdev, hopefully
> > someone there will know which rcu_dereference() is indicated.
>=20
> This is already sorted out in David trees

Very good!!!  ;-)

> > > [   85.939528] [ INFO: suspicious rcu_dereference_check() usage. =
]
> > > [   85.939531] --------------------------------------------------=
-
> > > [   85.939535] include/net/inet_timewait_sock.h:227 invoked
> > > rcu_dereference_check() without protection!
> > > [   85.939539]
> > > [   85.939540] other info that might help us debug this:
> > > [   85.939541]
> > > [   85.939544]
> > > [   85.939545] rcu_scheduler_active =3D 1, debug_locks =3D 1
> > > [   85.939549] 2 locks held by gwibber-service/4798:
> > > [   85.939552]  #0:  (&p->lock){+.+.+.}, at: [<ffffffff811034b2>]
> > > seq_read+0x37/0x381
> > > [   85.939566]  #1:  (&(&hashinfo->ehash_locks[i])->rlock){+.-...=
},
> > > at: [<ffffffff81386355>] established_get_next+0xc4/0x132
> > > [   85.939579]
> > > [   85.939580] stack backtrace:
> > > [   85.939585] Pid: 4798, comm: gwibber-service Not tainted 2.6.3=
4-rc5 #18
> > > [   85.939588] Call Trace:
> > > [   85.939598]  [<ffffffff81067fc2>] lockdep_rcu_dereference+0x9d=
/0xa5
> > > [   85.939604]  [<ffffffff81385018>] twsk_net+0x4f/0x57
> > > [   85.939610]  [<ffffffff813862e5>] established_get_next+0x54/0x=
132
> > > [   85.939615]  [<ffffffff813864c7>] tcp_seq_next+0x5d/0x6a
> > > [   85.939621]  [<ffffffff81103701>] seq_read+0x286/0x381
> > > [   85.939627]  [<ffffffff8110347b>] ? seq_read+0x0/0x381
> > > [   85.939633]  [<ffffffff81133240>] proc_reg_read+0x8d/0xac
> > > [   85.939640]  [<ffffffff810ea110>] vfs_read+0xa6/0x103
> > > [   85.939645]  [<ffffffff810ea223>] sys_read+0x45/0x69
> > > [   85.939652]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x=
1b
> >=20
> > This one appears to be a case of missing rcu_read_lock(), but it is
> > not clear to me at what level it needs to go.
> >=20
> > Eric, any enlightenment on this one and the next one?
>=20
> Coming from commit b099ce2602d806deb41caaa578731848995cdb2a
> >From Eric Biederman (CCed)
>=20
> Apparently he added rcu to twsk_net(), but Changelog doesnt mention i=
t.

Thank you for chasing this down, Eric Dumazet!

Eric Biederman, any enlightment?

							Thanx, Paul

> > > [   87.296366] [ INFO: suspicious rcu_dereference_check() usage. =
]
> > > [   87.296369] --------------------------------------------------=
-
> > > [   87.296373] include/net/inet_timewait_sock.h:227 invoked
> > > rcu_dereference_check() without protection!
> > > [   87.296377]
> > > [   87.296377] other info that might help us debug this:
> > > [   87.296379]
> > > [   87.296382]
> > > [   87.296383] rcu_scheduler_active =3D 1, debug_locks =3D 1
> > > [   87.296386] no locks held by gwibber-service/4803.
> > > [   87.296389]
> > > [   87.296390] stack backtrace:
> > > [   87.296395] Pid: 4803, comm: gwibber-service Not tainted 2.6.3=
4-rc5 #18
> > > [   87.296398] Call Trace:
> > > [   87.296411]  [<ffffffff81067fc2>] lockdep_rcu_dereference+0x9d=
/0xa5
> > > [   87.296419]  [<ffffffff813733d3>] twsk_net+0x4f/0x57
> > > [   87.296424]  [<ffffffff813737f3>] __inet_twsk_hashdance+0x50/0=
x158
> > > [   87.296431]  [<ffffffff81389239>] tcp_time_wait+0x1c1/0x24b
> > > [   87.296437]  [<ffffffff8137c417>] tcp_fin+0x83/0x162
> > > [   87.296443]  [<ffffffff8137cda7>] tcp_data_queue+0x1ff/0xa1e
> > > [   87.296450]  [<ffffffff810495c6>] ? mod_timer+0x1e/0x20
> > > [   87.296456]  [<ffffffff813809e3>] tcp_rcv_state_process+0x89d/=
0x8f2
> > > [   87.296463]  [<ffffffff8133ca0b>] ? release_sock+0x30/0x10b
> > > [   87.296468]  [<ffffffff81386df2>] tcp_v4_do_rcv+0x2de/0x33f
> > > [   87.296475]  [<ffffffff8133ca5d>] release_sock+0x82/0x10b
> > > [   87.296481]  [<ffffffff81376ef5>] tcp_close+0x1b5/0x37e
> > > [   87.296487]  [<ffffffff81395437>] inet_release+0x50/0x57
> > > [   87.296493]  [<ffffffff8133a134>] sock_release+0x1a/0x66
> > > [   87.296498]  [<ffffffff8133a1a2>] sock_close+0x22/0x26
> > > [   87.296505]  [<ffffffff810eb003>] __fput+0x120/0x1cd
> > > [   87.296510]  [<ffffffff810eb0c5>] fput+0x15/0x17
> > > [   87.296516]  [<ffffffff810e7f3d>] filp_close+0x63/0x6d
> > > [   87.296521]  [<ffffffff810e801e>] sys_close+0xd7/0x111
> > > [   87.296528]  [<ffffffff81002b6b>] system_call_fastpath+0x16/0x=
1b
> >=20
> > commit d3b8ba1bde9afb7d50cf0712f9d95317ea66c06f
> > Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Date:   Wed Apr 21 14:04:56 2010 -0700
> >=20
> >     sched: protect __sched_setscheduler() access to cgroups
> >    =20
> >     A given task's cgroups structures must remain while that task i=
s running
> >     due to reference counting, so this is presumably a false positi=
ve.
> >    =20
> >     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> >=20
> > diff --git a/kernel/sched.c b/kernel/sched.c
> > index 14c44ec..1d43c1a 100644
> > --- a/kernel/sched.c
> > +++ b/kernel/sched.c
> > @@ -4575,9 +4575,11 @@ recheck:
> >  		 * Do not allow realtime tasks into groups that have no runtime
> >  		 * assigned.
> >  		 */
> > +		rcu_read_lock();
> >  		if (rt_bandwidth_enabled() && rt_policy(policy) &&
> >  				task_group(p)->rt_bandwidth.rt_runtime =3D=3D 0)
> >  			return -EPERM;
> > +		rcu_read_unlock();
> >  #endif
> > =20
> >  		retval =3D security_task_setscheduler(p, policy, param);
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-ker=
nel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> >=20
>=20
>=20

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tproxy related crash in inet_hashtables
Date: Fri, 13 Aug 2010 15:55:36 +0200
Message-ID: <1281707736.4470.53.camel@edumazet-laptop>
References: <4C64FF2E.6060509@exinda.com>
	 <1281696852.4470.20.camel@edumazet-laptop>  <4C65432F.4030809@exinda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	KOVACS Krisztian <hidden@sch.bme.hu>
To: Stephen Buck <stephen.buck@exinda.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C65432F.4030809@exinda.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 13 ao=C3=BBt 2010 =C3=A0 23:05 +1000, Stephen Buck a =C3=A9=
crit :
> On 13/08/10 20:54, Eric Dumazet wrote:
> > Le vendredi 13 ao=C3=BBt 2010 =C3=A0 18:15 +1000, Stephen Buck a =C3=
=A9crit :
> >> Recently I encountered a number of crashes related to tproxy on th=
e
> >> 2.6.34.1 (x86_64 SMP) kernel. These usually manifested as a bug li=
ke the
> >> following (Although the bug was confirmed to be present on a vanil=
la
> >> kernel, this particular trace is from a kernel with some customisa=
tions):
> >>
> >> [ 1504.765077] BUG: unable to handle kernel NULL pointer dereferen=
ce at
> >> (null)
> >> [ 1504.848183] IP: [<ffffffff8135a79b>] inet_bind_bucket_destroy+0=
x1b/0x30
> >> [ 1504.927126] PGD 1a9933067 PUD 1ad909067 PMD 0
> >> [ 1504.980125] Thread overran stack, or stack corrupted
> >> [ 1505.039325] Oops: 0002 #1 SMP
> >> [ 1505.077775] last sysfs file:
> >> /sys/devices/system/cpu/cpu15/topology/thread_siblings
> >> [ 1505.169166] CPU 0
> >> [ 1505.193070] Modules linked in: sch_sfq cls_fw sch_htb xt_physde=
v
> >> 8021q bridge stp llc
> >> [ 1505.923769] Pid: 0, comm: swapper Not tainted 2.6.31-12EXINDAsm=
p #0
> >> PowerEdge R710
> >> [ 1506.014118] RIP: 0010:[<ffffffff8135a79b>] [<ffffffff8135a79b>]
> >> inet_bind_bucket_destroy+0x1b/0x30
> >> [ 1506.122242] RSP: 0018:ffffc90000003e10 EFLAGS: 00010246
> >> [ 1506.185655] RAX: 0000000000000000 RBX: ffffc900164a02a0 RCX:
> >> ffffea00098e24b0
> >> [ 1506.270863] RDX: 0000000000000000 RSI: ffff8802e1186280 RDI:
> >> ffffffff815b4600
> >> [ 1506.356077] RBP: ffffc90000003e10 R08: 0000000000000016 R09:
> >> 0000000000000001
> >> [ 1506.441284] R10: 0000000000000000 R11: 0000000000000000 R12:
> >> ffff88011b894fc0
> >> [ 1506.526500] R13: ffffffff81744c80 R14: ffffffff815fe6c0 R15:
> >> 0000000000000003
> >> [ 1506.611722] FS: 0000000000000000(0000) GS:ffffc90000000000(0000=
)
> >> knlGS:0000000000000000
> >> [ 1506.708410] CS: 0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> >> [ 1506.777011] CR2: 0000000000000000 CR3: 00000001ae17a000 CR4:
> >> 00000000000006f0
> >> [ 1506.862225] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> >> 0000000000000000
> >> [ 1506.947442] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> >> 0000000000000400
> >> [ 1507.032650] Process swapper (pid: 0, threadinfo ffffffff815b000=
0,
> >> task ffffffff815b6bc0)
> >> [ 1507.129345] Stack:
> >> [ 1507.153299] ffffc90000003e40 ffffffff8135b834 0000000000000001
> >> ffff88011b894fc0
> >> [ 1507.239581]<0>  ffffffff815fe560 0000000000000002 ffffc90000003=
e80
> >> ffffffff8135bbf6
> >> [ 1507.331133]<0>  ffffffff815fe560 ffffffff815fe560 ffffffff815fe=
6c0
> >> ffffc90000003eb0
> >> [ 1507.424833] Call Trace:
> >> [ 1507.453976]<IRQ>
> >> [ 1507.478971] [<ffffffff8135b834>] __inet_twsk_kill+0xb4/0xf0
> >> [ 1507.546538] [<ffffffff8135bbf6>] inet_twdr_do_twkill_work+0x66/=
0xd0
> >> [ 1507.622408] [<ffffffff8135bd40>] ? inet_twdr_hangman+0x0/0xd0
> >> [ 1507.692041] [<ffffffff8135bd95>] inet_twdr_hangman+0x55/0xd0
> >> [ 1507.760650] [<ffffffff810515ec>] run_timer_softirq+0x18c/0x220
> >> [ 1507.831330] [<ffffffff8104c3b8>] __do_softirq+0xc8/0x1f0
> >> [ 1507.895799] [<ffffffff8100cf5c>] call_softirq+0x1c/0x30
> >> [ 1507.959209] [<ffffffff8100e5f5>] do_softirq+0x45/0x80
> >> [ 1508.020538] [<ffffffff8104c2e7>] irq_exit+0x87/0x90
> >> [ 1508.079797] [<ffffffff813bd0c1>] smp_apic_timer_interrupt+0x71/=
0x9d
> >> [ 1508.155667] [<ffffffff8100c933>] apic_timer_interrupt+0x13/0x20
> >> [ 1508.227385]<EOI>
> >> [ 1508.252383] [<ffffffff8101317e>] ? mwait_idle+0x7e/0x110
> >> [ 1508.316836] [<ffffffff813bb0bd>] ? __atomic_notifier_call_chain=
+0xd/0x10
> >> [ 1508.397903] [<ffffffff813bb0d1>] ? atomic_notifier_call_chain+0=
x11/0x20
> >> [ 1508.477928] [<ffffffff8100ac31>] ? cpu_idle+0x51/0x90
> >> [ 1508.539265] [<ffffffff813aa92b>] ? rest_init+0x6b/0x80
> >> [ 1508.601639] [<ffffffff816230f5>] ? start_kernel+0x2c5/0x370
> >> [ 1508.669200] [<ffffffff81622611>] ? x86_64_start_reservations+0x=
81/0xc0
> >> [ 1508.748192] [<ffffffff81622726>] ? x86_64_start_kernel+0xd6/0x1=
00
> >> [ 1508.821979] Code: 64 10 40 eb 94 0f 1f 44 00 00 66 0f 1f 44 00 =
00 55
> >> 48 89 e5 0f 1f 44 00 00 48 83 7e 18 00 75 19 48 8b 46 08 48 8b 56 =
10
> >> [ 1509.048123] RIP [<ffffffff8135a79b>] inet_bind_bucket_destroy+0=
x1b/0x30
> >> [ 1509.128157] RSP<ffffc90000003e10>
> >> [ 1509.169759] CR2: 0000000000000000
> >>
> >>
> >> After spending a while tracking it down, I discovered that the wro=
ng
> >> locks get held when operating on the bind hash table's chains.
> >>
> >> This is due to the listen socket and the child socket having diffe=
rent
> >> local ports when __inet_inherit_port() is called. The lock is held=
 based
> >> on the child socket's port, but the list operated on is the one th=
e
> >> listen socket belongs to.
> >>
> >> e.g.
> >> There is a transparent proxy listening on port 9999.
> >> A new http connection (with port 80) is redirected to the proxy.
> >>
> >> The inet_bind_hashbucket locked in this case is table->bhash[80].l=
ock,
> >> but the inet_bind_bucket the child socket is added to is in the ch=
ain of
> >> the table->bhash[9999] inet_bind_hashbucket. This means that if an=
other
> >> connection with a different local port arrived and was redirected =
to the
> >> proxy, they could both be operating on the list at the same time.
> >>
> >>
> >> Attached is a patch that should fix this by looking up the correct
> >> inet_bind_bucket based on the child's local port when the
> >> inet_bind_bucket from the listen socket has a different port to th=
e
> >> child's inet_num. It was built against 2.6.34.1, but should apply =
to any
> >> mainline kernel.
> >>
> >> It is also possible the same bug exists in the IPv6 code as well. =
As I
> >> have not had to deal with IPv6 yet, I have not had a look.
> > Hi Stephen
> >
> > CC netfilter-devel&  Patrick&  Krisztian
> >
> > I cannot convince myself this patch is a right fix.
> >
> > This probably should be fixed in netfilter tree, not in
> > net/ipv4/inet_hashtables.c ?
> >
> > Once tproxy is involved, the original port (80) should be changed t=
o
> > 9999 by tproxy (for SYN packet) and conntrack for following ones.
> >
> > So listening socket and its children all use source port 9999 ?
> >
> > (inet_sk(child)->inet_num =3D=3D inet_sk(parent)->inet_num)
> I think you are referring to the older method of transparent proxying=
=2E=20
> Tproxy4 does not rely on conntrack. The socket is created with the=20
> connection's original ports and IPs.

So in your case "netstat -atn" displays port 80 , not port 9999 for
children, and 9999 for the listener ?=20

> >
> > You claim wrong lock is taken at insert time, but are you sure the =
right
> > lock is taken at deletion time ?
> >
> > Hmm...
> >
> Without the patch, you have the same problem in __inet_put_port(). Th=
e=20
> lock is taken based on the child's inet_num, but the icsk_bind_hash o=
f=20
> the socket was inherited from the parent, so it belongs to a differen=
t=20
> inet_bind_hashbucket.
>=20
> With the patch, inet_bind_hash refers to the inet_bind_bucket that wa=
s=20
> found by searching the hash table, rather than directly inherited fro=
m=20
> the parent. This means that the correct lock is chosen for the list=20
> being manipulated.

Really ?

So lock[80] is taken at insert time (as your patch doesnt change
locking), and lock[9999] taken at delete time ? How comes it doesnt
race ?


Look I am _very_ confused by this stuff.

How can you explain lock is taken on table->bhash[80].lock but your
patch adds a chain to table->bhash[9999] ? This is not what your patch
is trying to do. Or you should lock table->bhash[9999].lock=20


Please check the comment in front of inet_bind_bucket_create() :

/*
 * Allocate and initialize a new local port bind bucket.
 * The bindhash mutex for snum's hash chain must be held here.
 */

Maybe change this comment, because clearly "snum's hash" meaning is ver=
y
different after tproxy inclusion (and your patch) ?

Your patch Changelog is not clear enough, or very misleading ...

commit f517f61e37907ea66e48f224c135a9e1c257bb04
Author: Stephen Buck <stephen.buck@exinda.com>
Date:   Thu Aug 12 16:19:19 2010 +1000

    Fix locking issue in inet_hashtables when using tproxy
   =20
    When __inet_inherit_port() is called on a tproxy connection the wro=
ng locks
    are held for the inet_bind_bucket it is added to.



Since your patch does nothing about the lock itself, but adds a=20
new struct inet_bind_bucket in case the parent one is not appropriate, =
and
another sibling is not yet present.

I suggest you include in ChangeLog _all_ your email, because I am
pretty sure nobody will understand the intent of your patch in 2011.

I am sure the full explanation is better than a very short log entry.

Thanks


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

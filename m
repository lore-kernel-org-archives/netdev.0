From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tproxy related crash in inet_hashtables
Date: Fri, 13 Aug 2010 12:54:12 +0200
Message-ID: <1281696852.4470.20.camel@edumazet-laptop>
References: <4C64FF2E.6060509@exinda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	KOVACS Krisztian <hidden@sch.bme.hu>
To: Stephen Buck <stephen.buck@exinda.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C64FF2E.6060509@exinda.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 13 ao=C3=BBt 2010 =C3=A0 18:15 +1000, Stephen Buck a =C3=A9=
crit :
> Recently I encountered a number of crashes related to tproxy on the=20
> 2.6.34.1 (x86_64 SMP) kernel. These usually manifested as a bug like =
the=20
> following (Although the bug was confirmed to be present on a vanilla=20
> kernel, this particular trace is from a kernel with some customisatio=
ns):
>=20
> [ 1504.765077] BUG: unable to handle kernel NULL pointer dereference =
at=20
> (null)
> [ 1504.848183] IP: [<ffffffff8135a79b>] inet_bind_bucket_destroy+0x1b=
/0x30
> [ 1504.927126] PGD 1a9933067 PUD 1ad909067 PMD 0
> [ 1504.980125] Thread overran stack, or stack corrupted
> [ 1505.039325] Oops: 0002 #1 SMP
> [ 1505.077775] last sysfs file:=20
> /sys/devices/system/cpu/cpu15/topology/thread_siblings
> [ 1505.169166] CPU 0
> [ 1505.193070] Modules linked in: sch_sfq cls_fw sch_htb xt_physdev=20
> 8021q bridge stp llc
> [ 1505.923769] Pid: 0, comm: swapper Not tainted 2.6.31-12EXINDAsmp #=
0=20
> PowerEdge R710
> [ 1506.014118] RIP: 0010:[<ffffffff8135a79b>] [<ffffffff8135a79b>]=20
> inet_bind_bucket_destroy+0x1b/0x30
> [ 1506.122242] RSP: 0018:ffffc90000003e10 EFLAGS: 00010246
> [ 1506.185655] RAX: 0000000000000000 RBX: ffffc900164a02a0 RCX:=20
> ffffea00098e24b0
> [ 1506.270863] RDX: 0000000000000000 RSI: ffff8802e1186280 RDI:=20
> ffffffff815b4600
> [ 1506.356077] RBP: ffffc90000003e10 R08: 0000000000000016 R09:=20
> 0000000000000001
> [ 1506.441284] R10: 0000000000000000 R11: 0000000000000000 R12:=20
> ffff88011b894fc0
> [ 1506.526500] R13: ffffffff81744c80 R14: ffffffff815fe6c0 R15:=20
> 0000000000000003
> [ 1506.611722] FS: 0000000000000000(0000) GS:ffffc90000000000(0000)=20
> knlGS:0000000000000000
> [ 1506.708410] CS: 0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> [ 1506.777011] CR2: 0000000000000000 CR3: 00000001ae17a000 CR4:=20
> 00000000000006f0
> [ 1506.862225] DR0: 0000000000000000 DR1: 0000000000000000 DR2:=20
> 0000000000000000
> [ 1506.947442] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:=20
> 0000000000000400
> [ 1507.032650] Process swapper (pid: 0, threadinfo ffffffff815b0000,=20
> task ffffffff815b6bc0)
> [ 1507.129345] Stack:
> [ 1507.153299] ffffc90000003e40 ffffffff8135b834 0000000000000001=20
> ffff88011b894fc0
> [ 1507.239581] <0> ffffffff815fe560 0000000000000002 ffffc90000003e80=
=20
> ffffffff8135bbf6
> [ 1507.331133] <0> ffffffff815fe560 ffffffff815fe560 ffffffff815fe6c0=
=20
> ffffc90000003eb0
> [ 1507.424833] Call Trace:
> [ 1507.453976] <IRQ>
> [ 1507.478971] [<ffffffff8135b834>] __inet_twsk_kill+0xb4/0xf0
> [ 1507.546538] [<ffffffff8135bbf6>] inet_twdr_do_twkill_work+0x66/0xd=
0
> [ 1507.622408] [<ffffffff8135bd40>] ? inet_twdr_hangman+0x0/0xd0
> [ 1507.692041] [<ffffffff8135bd95>] inet_twdr_hangman+0x55/0xd0
> [ 1507.760650] [<ffffffff810515ec>] run_timer_softirq+0x18c/0x220
> [ 1507.831330] [<ffffffff8104c3b8>] __do_softirq+0xc8/0x1f0
> [ 1507.895799] [<ffffffff8100cf5c>] call_softirq+0x1c/0x30
> [ 1507.959209] [<ffffffff8100e5f5>] do_softirq+0x45/0x80
> [ 1508.020538] [<ffffffff8104c2e7>] irq_exit+0x87/0x90
> [ 1508.079797] [<ffffffff813bd0c1>] smp_apic_timer_interrupt+0x71/0x9=
d
> [ 1508.155667] [<ffffffff8100c933>] apic_timer_interrupt+0x13/0x20
> [ 1508.227385] <EOI>
> [ 1508.252383] [<ffffffff8101317e>] ? mwait_idle+0x7e/0x110
> [ 1508.316836] [<ffffffff813bb0bd>] ? __atomic_notifier_call_chain+0x=
d/0x10
> [ 1508.397903] [<ffffffff813bb0d1>] ? atomic_notifier_call_chain+0x11=
/0x20
> [ 1508.477928] [<ffffffff8100ac31>] ? cpu_idle+0x51/0x90
> [ 1508.539265] [<ffffffff813aa92b>] ? rest_init+0x6b/0x80
> [ 1508.601639] [<ffffffff816230f5>] ? start_kernel+0x2c5/0x370
> [ 1508.669200] [<ffffffff81622611>] ? x86_64_start_reservations+0x81/=
0xc0
> [ 1508.748192] [<ffffffff81622726>] ? x86_64_start_kernel+0xd6/0x100
> [ 1508.821979] Code: 64 10 40 eb 94 0f 1f 44 00 00 66 0f 1f 44 00 00 =
55=20
> 48 89 e5 0f 1f 44 00 00 48 83 7e 18 00 75 19 48 8b 46 08 48 8b 56 10
> [ 1509.048123] RIP [<ffffffff8135a79b>] inet_bind_bucket_destroy+0x1b=
/0x30
> [ 1509.128157] RSP <ffffc90000003e10>
> [ 1509.169759] CR2: 0000000000000000
>=20
>=20
> After spending a while tracking it down, I discovered that the wrong=20
> locks get held when operating on the bind hash table's chains.
>=20
> This is due to the listen socket and the child socket having differen=
t=20
> local ports when __inet_inherit_port() is called. The lock is held ba=
sed=20
> on the child socket's port, but the list operated on is the one the=20
> listen socket belongs to.
>=20
> e.g.
> There is a transparent proxy listening on port 9999.
> A new http connection (with port 80) is redirected to the proxy.
>=20
> The inet_bind_hashbucket locked in this case is table->bhash[80].lock=
,=20
> but the inet_bind_bucket the child socket is added to is in the chain=
 of=20
> the table->bhash[9999] inet_bind_hashbucket. This means that if anoth=
er=20
> connection with a different local port arrived and was redirected to =
the=20
> proxy, they could both be operating on the list at the same time.
>=20
>=20
> Attached is a patch that should fix this by looking up the correct=20
> inet_bind_bucket based on the child's local port when the=20
> inet_bind_bucket from the listen socket has a different port to the=20
> child's inet_num. It was built against 2.6.34.1, but should apply to =
any=20
> mainline kernel.
>=20
> It is also possible the same bug exists in the IPv6 code as well. As =
I=20
> have not had to deal with IPv6 yet, I have not had a look.

Hi Stephen

CC netfilter-devel & Patrick & Krisztian

I cannot convince myself this patch is a right fix.

This probably should be fixed in netfilter tree, not in
net/ipv4/inet_hashtables.c ?

Once tproxy is involved, the original port (80) should be changed to
9999 by tproxy (for SYN packet) and conntrack for following ones.

So listening socket and its children all use source port 9999 ?

(inet_sk(child)->inet_num =3D=3D inet_sk(parent)->inet_num)


You claim wrong lock is taken at insert time, but are you sure the righ=
t
lock is taken at deletion time ?

Hmm...


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with  "alive" pppoe interfaces
Date: Mon, 19 Oct 2009 15:01:14 +0300
Message-ID: <200910191501.15009.denys@visp.net.lb>
References: <200910190002.39937.denys@visp.net.lb> <e6d1cecd0910182034t9d24859mc6f392875b36ad17@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Michal Ostrowski <mostrows@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:50572 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbZJSMDK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 08:03:10 -0400
In-Reply-To: <e6d1cecd0910182034t9d24859mc6f392875b36ad17@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applied patch manually, still panic (maybe different now):

[   42.596904]
[   42.596904] Pid: 0, comm: swapper Not tainted (2.6.31.4-build-0047 #=
12)
[   42.596904] EIP: 0060:[<f886865e>] EFLAGS: 00010286 CPU: 0
[   42.596904] EIP is at pppoe_rcv+0x153/0x1be [pppoe]
[   42.596904] EAX: 00003100 EBX: ffffffff ECX: 00000002 EDX: f74007cb
[   42.596904] ESI: f79b4b00 EDI: f6332f00 EBP: c1806edc ESP: c1806eb8
[   42.596904]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[   42.596904] Process swapper (pid: 0, ti=3Dc1806000 task=3Dc03f6de0=20
task.ti=3Dc03f1000)
[   42.596904] Stack:
[   42.596904]  f7445000
00000004
f6fc0028
31000030
f6fc0030
f6332f40
f79b4b00
c0418140
Oct 19 15:00:46 194.146.153.99
[   42.596904] <0>
f886a444
c1806f14
c029e702
f7445000
f79b4bb0
f79b4bb0
c0418160
f7445000
Oct 19 15:00:46 194.146.153.99
[   42.596904] <0>
00000000
00000001
64886f14
c02ac3ce
f79b4b00
00000000
f753105c
c1806f58
Oct 19 15:00:46 194.146.153.99
[   42.596904] Call Trace:
[   42.596904]  [<c029e702>] ? netif_receive_skb+0x43b/0x45a
[   42.596904]  [<c02ac3ce>] ? eth_type_trans+0x25/0xa9
[   42.596904]  [<f840f736>] ? rtl8169_rx_interrupt+0x343/0x3f3 [r8169]
[   42.596904]  [<f8412191>] ? rtl8169_poll+0x2f/0x1b2 [r8169]
[   42.596904]  [<c01413e5>] ? hrtimer_run_pending+0x2d/0xa7
[   42.596904]  [<c029ec95>] ? net_rx_action+0x93/0x177
[   42.596904]  [<c0131bdd>] ? __do_softirq+0xa7/0x144
[   42.596904]  [<c0131b36>] ? __do_softirq+0x0/0x144
[   42.596904]  <IRQ>
Oct 19 15:00:46 194.146.153.99
[   42.596904]  [<c0131957>] ? irq_exit+0x29/0x5c
[   42.596904]  [<c0104393>] ? do_IRQ+0x80/0x96
[   42.596904]  [<c0102f49>] ? common_interrupt+0x29/0x30
[   42.596904]  [<c0108a3e>] ? mwait_idle+0x8a/0xb9
[   42.596904]  [<c0149613>] ? tick_nohz_restart_sched_tick+0x27/0x12f
[   42.596904]  [<c0101bf0>] ? cpu_idle+0x44/0x60
[   42.596904]  [<c02ef8c7>] ? rest_init+0x53/0x55
[   42.596904]  [<c04197df>] ? start_kernel+0x2b9/0x2be
[   42.596904]  [<c041906a>] ? i386_start_kernel+0x6a/0x6f
[   42.596904] Code:
53
0a
32
53
0b
31
c2
c1
e8
08
31
c2
eb
08
0f
b6
c2
c1
f8
04
31
c2
d1
e9
83
f9
04
74
f1
89
d0
83
e0
0f
8b
1c
87
eb
35
66
8b
45
ea
Oct 19 15:00:46 194.146.153.99
39
83
98
01
00
00
75
22
8b
55
e4
8d
83
9a
01
00
00
b9
06
00
Oct 19 15:00:46 194.146.153.99
[   42.596904] EIP: [<f886865e>]
pppoe_rcv+0x153/0x1be [pppoe]
SS:ESP 0068:c1806eb8
[   42.596904] CR2: 0000000000000197
[   42.606148] ---[ end trace b477ff4ee072d9b9 ]---
[   42.606209] Kernel panic - not syncing: Fatal exception in interrupt
[   42.606273] Pid: 0, comm: swapper Tainted: G      D    2.6.31.4-buil=
d-0047=20
#12
[   42.606351] Call Trace:
[   42.606413]  [<c02fc496>] ? printk+0xf/0x11
[   42.606474]  [<c02fc3e7>] panic+0x39/0xd9
[   42.606535]  [<c01059b7>] oops_end+0x8b/0x9a
[   42.606597]  [<c0118f6d>] no_context+0x13d/0x147
[   42.606658]  [<c011908a>] __bad_area_nosemaphore+0x113/0x11b
[   42.606722]  [<c0121dc1>] ? check_preempt_wakeup+0x34/0x141
[   42.606862]  [<c01294bb>] ? try_to_wake_up+0x1aa/0x1b4
[   42.606930]  [<c0209541>] ? cpumask_next_and+0x26/0x37
[   42.607003]  [<c01256f5>] ? find_busiest_group+0x291/0x885
[   42.607067]  [<c019cf47>] ? pollwake+0x5a/0x63
[   42.607127]  [<c011909f>] bad_area_nosemaphore+0xd/0x10
[   42.607189]  [<c0119301>] do_page_fault+0x114/0x26f
[   42.607251]  [<c01191ed>] ? do_page_fault+0x0/0x26f
[   42.607313]  [<c02fe506>] error_code+0x66/0x6c
[   42.607375]  [<c02900d8>] ? pcibios_set_master+0x89/0x8d
[   42.607436]  [<c01191ed>] ? do_page_fault+0x0/0x26f
[   42.607501]  [<f886865e>] ? pppoe_rcv+0x153/0x1be [pppoe]
[   42.607564]  [<c029e702>] netif_receive_skb+0x43b/0x45a
[   42.607625]  [<c02ac3ce>] ? eth_type_trans+0x25/0xa9
[   42.607691]  [<f840f736>] rtl8169_rx_interrupt+0x343/0x3f3 [r8169]
[   42.607759]  [<f8412191>] rtl8169_poll+0x2f/0x1b2 [r8169]
[   42.607824]  [<c01413e5>] ? hrtimer_run_pending+0x2d/0xa7
[   42.607886]  [<c029ec95>] net_rx_action+0x93/0x177
[   42.607948]  [<c0131bdd>] __do_softirq+0xa7/0x144
[   42.608022]  [<c0131b36>] ? __do_softirq+0x0/0x144
[   42.608082]  <IRQ>
[<c0131957>] ? irq_exit+0x29/0x5c
[   42.608183]  [<c0104393>] ? do_IRQ+0x80/0x96
[   42.608183]  [<c0104393>] ? do_IRQ+0x80/0x96
[   42.608245]  [<c0102f49>] ? common_interrupt+0x29/0x30
[   42.608307]  [<c0108a3e>] ? mwait_idle+0x8a/0xb9
[   42.608369]  [<c0149613>] ? tick_nohz_restart_sched_tick+0x27/0x12f
[   42.608431]  [<c0101bf0>] ? cpu_idle+0x44/0x60
[   42.608493]  [<c02ef8c7>] ? rest_init+0x53/0x55
[   42.608553]  [<c04197df>] ? start_kernel+0x2b9/0x2be
[   42.608616]  [<c041906a>] ? i386_start_kernel+0x6a/0x6f
[   42.608682] Rebooting in 5 seconds..



On Monday 19 October 2009 06:34:06 Michal Ostrowski wrote:
> Here's my theory on this after an inital look...
>
> Looking at the oops report and disassembly of the actual module binar=
y
> that caused the oops, one can deduce that:
>
> Execution was in pppoe_flush_dev(). =A0%ebx contained the pointer "st=
ruct
> pppox_sock *po", which is what we faulted on, excuting "cmp %eax,
> 0x190(%ebx)". %ebx value was 0xffffffff (hence we got "NULL pointer
> dereference at 0x18f").
>
> At this point "i" (stored in %esi) is 15 (valid), meaning that we got=
 a
> value of 0xffffffff in pn->hash_table[i].
>
> From this I'd hypothesize that the combination of dev_put() and
> release_sock() may have allowed us to free "pn". =A0At the bottom of =
the loop
> we alreayd recognize that since locks are dropped we're responsible f=
or
> handling invalidation of objects, and perhaps that should be extended=
 to
> "pn" as well. --
> Michal Ostrowski
> mostrows@gmail.com
>
>
> ---
> =A0drivers/net/pppoe.c | =A0 86 ++++++++++++++++++++++++++----
> --------------------
> =A01 files changed, 45 insertions(+), 41 deletions(-)
>
> diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
> index 7cbf6f9..720c4ea 100644
> --- a/drivers/net/pppoe.c
> +++ b/drivers/net/pppoe.c
> @@ -296,6 +296,7 @@ static void pppoe_flush_dev(struct net_device *de=
v)
>
> =A0 =A0 =A0 =A0BUG_ON(dev =3D=3D NULL);
>
> +restart:
> =A0 =A0 =A0 =A0pn =3D pppoe_pernet(dev_net(dev));
> =A0 =A0 =A0 =A0if (!pn) /* already freed */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> @@ -303,48 +304,51 @@ static void pppoe_flush_dev(struct net_device *=
dev)
> =A0 =A0 =A0 =A0write_lock_bh(&pn->hash_lock);
> =A0 =A0 =A0 =A0for (i =3D 0; i < PPPOE_HASH_SIZE; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct pppox_sock *po =3D pn->hash_tab=
le[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sock *sk;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (po !=3D NULL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sock *sk;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (po->pppoe_dev !=3D =
dev) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 po =3D =
po->next;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk =3D sk_pppox(po);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&flush_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 po->pppoe_dev =3D NULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&flush_lock=
);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_put(dev);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We always grab the s=
ocket lock, followed by the
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* hash_lock, in that=
 order. =A0Since we should
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* hold the sock lock=
 while doing any unbinding,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we need to release=
 the lock we're holding.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Hold a reference t=
o the sock so it doesn't
> disappear - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* as we're=
 jumping between locks.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (po && po->pppoe_dev !=3D dev)=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0po =3D po->next;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sock_hold(sk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (po =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 write_unlock_bh(&pn->ha=
sh_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_sock(sk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sk =3D sk_pppox(po);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sk->sk_state & (PPP=
OX_CONNECTED | PPPOX_BOUND))
> { - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pppox=
_unbind_sock(sk);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk->sk_=
state =3D PPPOX_ZOMBIE;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk->sk_=
state_change(sk);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock(&flush_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0po->pppoe_dev =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&flush_lock);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 release_sock(sk);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sock_put(sk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_put(dev);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Restart scan at the =
beginning of this hash
> chain. - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* While the l=
ock was dropped the chain
> contents may - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* have =
changed.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 write_lock_bh(&pn->hash=
_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 po =3D pn->hash_table[i=
];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* We always grab the socket lock, f=
ollowed by the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * hash_lock, in that order. =A0Sinc=
e we should
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * hold the sock lock while doing an=
y unbinding,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * we need to release the lock we're=
 holding.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Hold a reference to the sock so i=
t doesn't disappear
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * as we're jumping between locks.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sock_hold(sk);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0write_unlock_bh(&pn->hash_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lock_sock(sk);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sk->sk_state & (PPPOX_CONNECTED =
| PPPOX_BOUND)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pppox_unbind_sock(sk=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sk->sk_state =3D PPP=
OX_ZOMBIE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sk->sk_state_change(=
sk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0release_sock(sk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sock_put(sk);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Restart the flush process from th=
e beginning. =A0While
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * the lock was dropped the chain co=
ntents may have
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * changed, and sock_put may have ma=
de things go away.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto restart;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0write_unlock_bh(&pn->hash_lock);
> =A0}
> --
> 1.6.3.3
>
> On Sun, Oct 18, 2009 at 4:02 PM, Denys Fedoryschenko <denys@visp.net.=
lb>=20
wrote:
> > I have server running as pppoe NAS.
> > Tried to rename customers without dropping pppd connections first, =
got
> > panic after few seconds.
> > Panic triggerable at 2.6.30.4 and 2.6.31.4
> > pppoe users running on eth2
> > pppoe flags:
> > =A01457 root =A0 =A0 /usr/sbin/pppoe-server -I eth2 -k -L 172.16.1.=
1 -R
> > 172.16.1.2 -N 253 -C gpzone -S gpzone
> >
> >
> > Commands sequence that i think triggered that:
> >
> > ip link set eth0 down
> > ip link set eth1 down
> > ip link set eth2 down
> > nameif etherx 00:16:76:8D:83:BA
> > nameif eth0 00:19:e0:72:4a:37
> > nameif eth1 00:19:e0:72:4a:4b
> >
> > ip addr flush dev eth0
> > ip addr flush dev eth1
> > ip addr add X.X.X.X/29 dev eth0
> > ip addr add 192.168.2.177/24 dev eth0
> > ip addr add 192.168.0.1/32 dev eth1
> > ip addr add 127.0.0.0/8 dev lo
> > #ip link set eth0 up
> > ip link set eth0 up
> > ip link set eth1 up
> > ip link set lo up
> > ip route add 0.0.0.0/0 via X.X.X.X
> >
> >
> > [ =A0103.428591] r8169: eth0: link up
> > [ =A0103.430360] r8169: eth1: link up
> > [ =A0113.361528] BUG: unable to handle kernel
> > NULL pointer dereference
> > at 0000018f
> > [ =A0113.361717] IP:
> > [<f8868269>] pppoe_device_event+0x80/0x12c [pppoe]
> > [ =A0113.361853] *pdpt =3D 000000003411a001
> > *pde =3D 0000000000000000
> > Oct 18 23:59:40 194.146.153.93
> > [ =A0113.362012] Oops: 0000 [#1]
> > SMP
> > Oct 18 23:59:40 194.146.153.93
> > [ =A0113.362166] last sysfs file: /sys/devices/virtual/vc/vcs3/dev
> > [ =A0113.362246] Modules linked in:
> > netconsole
> > configfs
> > act_skbedit
> > sch_ingress
> > sch_prio
> > cls_flow
> > cls_u32
> > em_meta
> > cls_basic
> > xt_dscp
> > xt_DSCP
> > ipt_REJECT
> > ts_bm
> > xt_string
> > xt_hl
> > ifb
> > cls_fw
> > sch_tbf
> > sch_htb
> > act_ipt
> > act_mirred
> > xt_MARK
> > pppoe
> > pppox
> > ppp_generic
> > slhc
> > xt_TCPMSS
> > xt_mark
> > xt_tcpudp
> > iptable_mangle
> > iptable_nat
> > nf_nat
> > rtc_cmos
> > nf_conntrack_ipv4
> > rtc_core
> > nf_conntrack
> > rtc_lib
> > nf_defrag_ipv4
> > iptable_filter
> > ip_tables
> > x_tables
> > 8021q
> > garp
> > stp
> > llc
> > loop
> > sata_sil
> > pata_atiixp
> > pata_acpi
> > ata_generic
> > libata
> > 8139cp
> > usb_storage
> > mtdblock
> > mtd_blkdevs
> > mtd
> > sr_mod
> > cdrom
> > tulip
> > r8169
> > sky2
> > via_velocity
> > via_rhine
> > sis900
> > ne2k_pci
> > 8390
> > skge
> > tg3
> > libphy
> > 8139too
> > e1000
> > e100
> > usbhid
> > ohci_hcd
> > uhci_hcd
> > ehci_hcd
> > usbcore
> > nls_base
> > Oct 18 23:59:40 194.146.153.93
> > [ =A0113.362344]
> > [ =A0113.362344] Pid: 2858, comm: pppd Not tainted (2.6.31.4-build-=
0047 #7)
> > [ =A0113.362344] EIP: 0060:[<f8868269>] EFLAGS: 00010286 CPU: 0
> > [ =A0113.362344] EIP is at pppoe_device_event+0x80/0x12c [pppoe]
> > [ =A0113.362344] EAX: f4fbe000 EBX: ffffffff ECX: f6cea5a0 EDX: f74=
03680
> > [ =A0113.362344] ESI: 0000000f EDI: f6cea5e0 EBP: f4145e34 ESP: f41=
45e1c
> > [ =A0113.362344] =A0DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> > [ =A0113.362344] Process pppd (pid: 2858, ti=3Df4145000 task=3Df411=
2ff0
> > task.ti=3Df4145000)
> > [ =A0113.362344] Stack:
> > [ =A0113.362344] =A0f4fbe220
> > f4fbe000
> > f6cea5a0
> > f886a430
> > fffffff5
> > 00000000
> > f4145e54
> > c01422b3
> > Oct 18 23:59:40 194.146.153.93
> > [ =A0113.362344] <0>
> > f4fbe000
> > 00000009
> > f8a457d8
> > f4fbe000
> > f8850190
> > 00001091
> > f4145e64
> > c0142361
> > Oct 18 23:59:40 194.146.153.93
> > [ =A0113.362344] <0>
> > ffffffff
> > 00000000
> > f4145e74
> > c029ffbf
> > f4fbe000
> > 000010d0
> > f4145e90
> > c029fa70
> > Oct 18 23:59:40 194.146.153.93
> > [ =A0113.362344] Call Trace:
> > [ =A0113.362344] =A0[<c01422b3>] ? notifier_call_chain+0x2b/0x4a
> > [ =A0113.362344] =A0[<c0142361>] ? raw_notifier_call_chain+0xc/0xe
> > [ =A0113.362344] =A0[<c029ffbf>] ? dev_close+0x4c/0x8c
> > [ =A0113.362344] =A0[<c029fa70>] ? dev_change_flags+0xa5/0x158
> > [ =A0113.362344] =A0[<c02da633>] ? devinet_ioctl+0x21a/0x503
> > [ =A0113.362344] =A0[<c02db693>] ? inet_ioctl+0x8d/0xa6
> > [ =A0113.362344] =A0[<c0292b21>] ? sock_ioctl+0x1c8/0x1ec
> > [ =A0113.362344] =A0[<c0292959>] ? sock_ioctl+0x0/0x1ec
> > [ =A0113.362344] =A0[<c019af2b>] ? vfs_ioctl+0x22/0x69
> > [ =A0113.362344] =A0[<c019b435>] ? do_vfs_ioctl+0x41f/0x459
> > [ =A0113.362344] =A0[<c02934eb>] ? sys_send+0x18/0x1a
> > [ =A0113.362344] =A0[<c011942f>] ? do_page_fault+0x242/0x26f
> > [ =A0113.362344] =A0[<c019b49b>] ? sys_ioctl+0x2c/0x45
> > [ =A0113.362344] =A0[<c0102975>] ? syscall_call+0x7/0xb
> > [ =A0113.362344] Code:
> > c9
> > 00
> > 00
> > 00
> > 89
> > c7
> > 31
> > f6
> > 83
> > c7
> > 40
> > 89
> > f8
> > e8
> > cc
> > 60
> > a9
> > c7
> > 8b
> > 45
> > ec
> > 05
> > 20
> > 02
> > 00
> > 00
> > 89
> > 45
> > e8
> > 8b
> > 4d
> > f0
> > 8b
> > 1c
> > b1
> > e9
> > 8c
> > 00
> > 00
> > 00
> > 8b
> > 45
> > ec
> > Oct 18 23:59:40 194.146.153.93
> > 83
> > 90
> > 01
> > 00
> > 00
> > 74
> > 08
> > 8b
> > 9b
> > 8c
> > 01
> > 00
> > 00
> > eb
> > 79
> > b8
> > c0
> > a6
> > 86
> > f8
> > Oct 18 23:59:40 194.146.153.93
> > [ =A0113.362344] EIP: [<f8868269>]
> > pppoe_device_event+0x80/0x12c [pppoe]
> > SS:ESP 0068:f4145e1c
> > [ =A0113.362344] CR2: 000000000000018f
> > [ =A0113.373124] ---[ end trace f6fe64a307e97f3b ]---
> > [ =A0113.373203] Kernel panic - not syncing: Fatal exception in int=
errupt
> > [ =A0113.373286] Pid: 2858, comm: pppd Tainted: G =A0 =A0 =A0D =A0
> > =A02.6.31.4-build-0047 #7
> > [ =A0113.373379] Call Trace:
> > [ =A0113.373479] =A0[<c02fc496>] ? printk+0xf/0x11
> > [ =A0113.373561] =A0[<c02fc3e7>] panic+0x39/0xd9
> > [ =A0113.373656] =A0[<c01059b7>] oops_end+0x8b/0x9a
> > [ =A0113.373727] =A0[<c0118f6d>] no_context+0x13d/0x147
> > [ =A0113.373800] =A0[<c011908a>] __bad_area_nosemaphore+0x113/0x11b
> > [ =A0113.373881] =A0[<c02953b3>] ? sock_alloc_send_pskb+0x8b/0x24a
> > [ =A0113.373959] =A0[<c0121801>] ? __wake_up_sync_key+0x3b/0x45
> > [ =A0113.374030] =A0[<c0131967>] ? irq_exit+0x39/0x5c
> > [ =A0113.374107] =A0[<c0104393>] ? do_IRQ+0x80/0x96
> > [ =A0113.374183] =A0[<c0102f49>] ? common_interrupt+0x29/0x30
> > [ =A0113.374259] =A0[<c011909f>] bad_area_nosemaphore+0xd/0x10
> > [ =A0113.374348] =A0[<c0119301>] do_page_fault+0x114/0x26f
> > [ =A0113.374526] =A0[<c01191ed>] ? do_page_fault+0x0/0x26f
> > [ =A0113.374605] =A0[<c02fe506>] error_code+0x66/0x6c
> > [ =A0113.374683] =A0[<c02d007b>] ? tcp_v4_send_ack+0xa3/0x10e
> > [ =A0113.374764] =A0[<c01191ed>] ? do_page_fault+0x0/0x26f
> > [ =A0113.374850] =A0[<f8868269>] ? pppoe_device_event+0x80/0x12c [p=
ppoe]
> > [ =A0113.374928] =A0[<c01422b3>] notifier_call_chain+0x2b/0x4a
> > [ =A0113.375012] =A0[<c0142361>] raw_notifier_call_chain+0xc/0xe
> > [ =A0113.375097] =A0[<c029ffbf>] dev_close+0x4c/0x8c
> > [ =A0113.375169] =A0[<c029fa70>] dev_change_flags+0xa5/0x158
> > [ =A0113.375239] =A0[<c02da633>] devinet_ioctl+0x21a/0x503
> > [ =A0113.375318] =A0[<c02db693>] inet_ioctl+0x8d/0xa6
> > [ =A0113.375411] =A0[<c0292b21>] sock_ioctl+0x1c8/0x1ec
> > [ =A0113.375491] =A0[<c0292959>] ? sock_ioctl+0x0/0x1ec
> > [ =A0113.375574] =A0[<c019af2b>] vfs_ioctl+0x22/0x69
> > [ =A0113.375653] =A0[<c019b435>] do_vfs_ioctl+0x41f/0x459
> > [ =A0113.375734] =A0[<c02934eb>] ? sys_send+0x18/0x1a
> > [ =A0113.375813] =A0[<c011942f>] ? do_page_fault+0x242/0x26f
> > [ =A0113.375884] =A0[<c019b49b>] sys_ioctl+0x2c/0x45
> > [ =A0113.375960] =A0[<c0102975>] syscall_call+0x7/0xb
> > [ =A0113.376041] Rebooting in 5 seconds..



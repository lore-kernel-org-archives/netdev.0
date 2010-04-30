From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: r8169 INFO: inconsistent lock state
Date: Fri, 30 Apr 2010 22:59:09 +0200
Message-ID: <1272661149.2230.11.camel@edumazet-laptop>
References: <20100430182012.GA3329@swordfish.minsk.epam.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:44609 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756216Ab0D3U7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 16:59:15 -0400
In-Reply-To: <20100430182012.GA3329@swordfish.minsk.epam.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 30 avril 2010 =C3=A0 21:20 +0300, Sergey Senozhatsky a =C3=A9=
crit :
> Hello,
>=20
> Yet another one (during resume):
>=20
> kernel: [ 1968.334646]=20
> kernel: [ 1968.334648] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> kernel: [ 1968.334651] [ INFO: inconsistent lock state ]
> kernel: [ 1968.334654] 2.6.34-rc6-dbg #105
> kernel: [ 1968.334656] ---------------------------------
> kernel: [ 1968.334659] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} =
usage.
> kernel: [ 1968.334663] events/1/3854 [HC0[0]:SC0[0]:HE1:SE1] takes:
> kernel: [ 1968.334666]  (&(&table->hash[i].lock)->rlock){+.?...}, at:=
 [<c1292ec4>] __udp4_lib_mcast_deliver+0x3c/0x143
> kernel: [ 1968.334678] {IN-SOFTIRQ-W} state was registered at:
> kernel: [ 1968.334681]   [<c104fc8d>] __lock_acquire+0x2ba/0xc01
> kernel: [ 1968.334688]   [<c10509df>] lock_acquire+0x5e/0x75
> kernel: [ 1968.334693]   [<c12c366a>] _raw_spin_lock+0x28/0x58
> kernel: [ 1968.334699]   [<c1292ec4>] __udp4_lib_mcast_deliver+0x3c/0=
x143
> kernel: [ 1968.334704]   [<c12931a7>] __udp4_lib_rcv+0x1dc/0x3ac
> kernel: [ 1968.334708]   [<c1293389>] udp_rcv+0x12/0x14
> kernel: [ 1968.334713]   [<c127605f>] ip_local_deliver_finish+0xd2/0x=
137
> kernel: [ 1968.334719]   [<c12760fc>] NF_HOOK.clone.1+0x38/0x3f
> kernel: [ 1968.334724]   [<c1276220>] ip_local_deliver+0x3c/0x42
> kernel: [ 1968.334728]   [<c1275f2e>] ip_rcv_finish+0x25c/0x27e
> kernel: [ 1968.334733]   [<c12760fc>] NF_HOOK.clone.1+0x38/0x3f
> kernel: [ 1968.334737]   [<c12763c9>] ip_rcv+0x1a3/0x1c6
> kernel: [ 1968.334741]   [<c12593d7>] netif_receive_skb+0x38b/0x3ab
> kernel: [ 1968.334747]   [<fd20f911>] rtl8169_rx_interrupt+0x2de/0x3e=
b [r8169]
> kernel: [ 1968.334756]   [<fd211cde>] rtl8169_poll+0x28/0x15d [r8169]
> kernel: [ 1968.334763]   [<c12596b3>] net_rx_action+0x93/0x181
> kernel: [ 1968.334767]   [<c1032a72>] __do_softirq+0x88/0x10c
> kernel: [ 1968.334773]   [<c1032b25>] do_softirq+0x2f/0x47
> kernel: [ 1968.334778]   [<c1032de2>] irq_exit+0x38/0x75
> kernel: [ 1968.334782]   [<c1004489>] do_IRQ+0x79/0x8d
> kernel: [ 1968.334787]   [<c1002db5>] common_interrupt+0x35/0x3c
> kernel: [ 1968.334791]   [<c1246f43>] cpuidle_idle_call+0x6a/0xa0
> kernel: [ 1968.334799]   [<c100171b>] cpu_idle+0x89/0xbe
> kernel: [ 1968.334802]   [<c12b3d49>] rest_init+0xd1/0xd6
> kernel: [ 1968.334807]   [<c147e7bd>] start_kernel+0x339/0x33e
> kernel: [ 1968.334813]   [<c147e0c9>] i386_start_kernel+0xc9/0xd0
> kernel: [ 1968.334818] irq event stamp: 63
> kernel: [ 1968.334820] hardirqs last  enabled at (63): [<c109d7ff>] k=
mem_cache_free+0x83/0x8f
> kernel: [ 1968.334828] hardirqs last disabled at (62): [<c109d7a6>] k=
mem_cache_free+0x2a/0x8f
> kernel: [ 1968.334833] softirqs last  enabled at (60): [<c126400a>] r=
cu_read_unlock_bh+0x1c/0x1e
> kernel: [ 1968.334839] softirqs last disabled at (58): [<c1263faf>] r=
cu_read_lock_bh+0x8/0x26
> kernel: [ 1968.334845]=20
> kernel: [ 1968.334846] other info that might help us debug this:
> kernel: [ 1968.334849] 5 locks held by events/1/3854:
> kernel: [ 1968.334851]  #0:  (events){+.+.+.}, at: [<c103c8e9>] worke=
r_thread+0x128/0x23c
> kernel: [ 1968.334859]  #1:  ((&(&tp->task)->work)){+.+...}, at: [<c1=
03c8e9>] worker_thread+0x128/0x23c
> kernel: [ 1968.334865]  #2:  (rtnl_mutex){+.+.+.}, at: [<c1262b8f>] r=
tnl_lock+0xf/0x11
> kernel: [ 1968.334871]  #3:  (rcu_read_lock){.+.+..}, at: [<c125784b>=
] rcu_read_lock+0x0/0x2b
> kernel: [ 1968.334877]  #4:  (rcu_read_lock){.+.+..}, at: [<c1275c56>=
] rcu_read_lock+0x0/0x2b
> kernel: [ 1968.334884]=20
> kernel: [ 1968.334885] stack backtrace:
> kernel: [ 1968.334888] Pid: 3854, comm: events/1 Not tainted 2.6.34-r=
c6-dbg #105
> kernel: [ 1968.334891] Call Trace:
> kernel: [ 1968.334895]  [<c12c1906>] ? printk+0xf/0x11
> kernel: [ 1968.334901]  [<c104e7d9>] valid_state+0x133/0x141
> kernel: [ 1968.334906]  [<c104e8b6>] mark_lock+0xcf/0x1bc
> kernel: [ 1968.334911]  [<c104e11f>] ? check_usage_backwards+0x0/0x72
> kernel: [ 1968.334915]  [<c104fcff>] __lock_acquire+0x32c/0xc01
> kernel: [ 1968.334922]  [<c129ee2d>] ? fib_table_lookup+0x81/0x8e
> kernel: [ 1968.334927]  [<c100772e>] ? __cycles_2_ns+0xf/0x3e
> kernel: [ 1968.334932]  [<c12671b6>] ? rcu_read_unlock+0x0/0x38
> kernel: [ 1968.334937]  [<c1007a30>] ? native_sched_clock+0x49/0x4f
> kernel: [ 1968.334943]  [<c10443a9>] ? sched_clock_local+0x11/0x11f
> kernel: [ 1968.334948]  [<c10509df>] lock_acquire+0x5e/0x75
> kernel: [ 1968.334953]  [<c1292ec4>] ? __udp4_lib_mcast_deliver+0x3c/=
0x143
> kernel: [ 1968.334958]  [<c12c366a>] _raw_spin_lock+0x28/0x58
> kernel: [ 1968.334963]  [<c1292ec4>] ? __udp4_lib_mcast_deliver+0x3c/=
0x143
> kernel: [ 1968.334967]  [<c1292ec4>] __udp4_lib_mcast_deliver+0x3c/0x=
143
> kernel: [ 1968.334973]  [<c104463c>] ? sched_clock_cpu+0x121/0x131
> kernel: [ 1968.334978]  [<c12735b5>] ? rcu_read_unlock+0x0/0x38
> kernel: [ 1968.334983]  [<c104463c>] ? sched_clock_cpu+0x121/0x131
> kernel: [ 1968.334988]  [<c10505c5>] ? __lock_acquire+0xbf2/0xc01
> kernel: [ 1968.334994]  [<c12735e2>] ? rcu_read_unlock+0x2d/0x38
> kernel: [ 1968.334998]  [<c1274034>] ? ip_route_input+0x101/0xaf4
> kernel: [ 1968.335003]  [<c12931a7>] __udp4_lib_rcv+0x1dc/0x3ac
> kernel: [ 1968.335008]  [<c1293389>] udp_rcv+0x12/0x14
> kernel: [ 1968.335013]  [<c127605f>] ip_local_deliver_finish+0xd2/0x1=
37
> kernel: [ 1968.335017]  [<c1275f8d>] ? ip_local_deliver_finish+0x0/0x=
137
> kernel: [ 1968.335022]  [<c12760fc>] NF_HOOK.clone.1+0x38/0x3f
> kernel: [ 1968.335026]  [<c1276220>] ip_local_deliver+0x3c/0x42
> kernel: [ 1968.335031]  [<c1275f8d>] ? ip_local_deliver_finish+0x0/0x=
137
> kernel: [ 1968.335035]  [<c1275f2e>] ip_rcv_finish+0x25c/0x27e
> kernel: [ 1968.335040]  [<c1275cd2>] ? ip_rcv_finish+0x0/0x27e
> kernel: [ 1968.335044]  [<c12760fc>] NF_HOOK.clone.1+0x38/0x3f
> kernel: [ 1968.335048]  [<c12763c9>] ip_rcv+0x1a3/0x1c6
> kernel: [ 1968.335052]  [<c1275cd2>] ? ip_rcv_finish+0x0/0x27e


> kernel: [ 1968.335057]  [<c12593d7>] netif_receive_skb+0x38b/0x3ab
> kernel: [ 1968.335066]  [<fd20f911>] rtl8169_rx_interrupt+0x2de/0x3eb=
 [r8169]
> kernel: [ 1968.335073]  [<fd20fc9b>] rtl8169_reset_task+0x33/0xe8 [r8=
169]

So we have following illegal chain (process context, not softirq)

rtl8169_reset_task() -> tl8169_rx_interrupt() -> netif_receive_skb()

And normally, commit 630b943c tried to change this chain to :

rtl8169_reset_task() -> tl8169_rx_interrupt() -> netif_rx()

I have no idea why it doesnt work.

commit 630b943c182d1aed69f244405131902fbcba7ec6
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Wed Mar 31 02:08:31 2010 +0000

    r8169: Fix rtl8169_rx_interrupt()
   =20
    In case a reset is performed, rtl8169_rx_interrupt() is called from
    process context instead of softirq context. Special care must be ta=
ken
    to call appropriate network core services (netif_rx() instead of
    netif_receive_skb()). VLAN handling also corrected.
   =20
    Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
    Tested-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
    Diagnosed-by: Oleg Nesterov <oleg@redhat.com>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 964305c..f7ffa5d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1054,14 +1054,14 @@ static void rtl8169_vlan_rx_register(struct net=
_device *dev,
 }
=20
 static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDe=
sc *desc,
-			       struct sk_buff *skb)
+			       struct sk_buff *skb, int polling)
 {
 	u32 opts2 =3D le32_to_cpu(desc->opts2);
 	struct vlan_group *vlgrp =3D tp->vlgrp;
 	int ret;
=20
 	if (vlgrp && (opts2 & RxVlanTag)) {
-		vlan_hwaccel_receive_skb(skb, vlgrp, swab16(opts2 & 0xffff));
+		__vlan_hwaccel_rx(skb, vlgrp, swab16(opts2 & 0xffff), polling);
 		ret =3D 0;
 	} else
 		ret =3D -1;
@@ -1078,7 +1078,7 @@ static inline u32 rtl8169_tx_vlan_tag(struct rtl8=
169_private *tp,
 }
=20
 static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDe=
sc *desc,
-			       struct sk_buff *skb)
+			       struct sk_buff *skb, int polling)
 {
 	return -1;
 }
@@ -4467,12 +4467,20 @@ out:
 	return done;
 }
=20
+/*
+ * Warning : rtl8169_rx_interrupt() might be called :
+ * 1) from NAPI (softirq) context
+ *	(polling =3D 1 : we should call netif_receive_skb())
+ * 2) from process context (rtl8169_reset_task())
+ *	(polling =3D 0 : we must call netif_rx() instead)
+ */
 static int rtl8169_rx_interrupt(struct net_device *dev,
 				struct rtl8169_private *tp,
 				void __iomem *ioaddr, u32 budget)
 {
 	unsigned int cur_rx, rx_left;
 	unsigned int delta, count;
+	int polling =3D (budget !=3D ~(u32)0) ? 1 : 0;
=20
 	cur_rx =3D tp->cur_rx;
 	rx_left =3D NUM_RX_DESC + tp->dirty_rx - cur_rx;
@@ -4534,8 +4542,12 @@ static int rtl8169_rx_interrupt(struct net_devic=
e *dev,
 			skb_put(skb, pkt_size);
 			skb->protocol =3D eth_type_trans(skb, dev);
=20
-			if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
-				netif_receive_skb(skb);
+			if (rtl8169_rx_vlan_skb(tp, desc, skb, polling) < 0) {
+				if (likely(polling))
+					netif_receive_skb(skb);
+				else
+					netif_rx(skb);
+			}
=20
 			dev->stats.rx_bytes +=3D pkt_size;
 			dev->stats.rx_packets++;



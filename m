From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Mon, 12 Apr 2010 00:35:53 +0200
Message-ID: <1271025353.2078.155.camel@edumazet-laptop>
References: <201004112338.47019.nuclearcat@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>
To: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:33711 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752982Ab0DKWf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 18:35:59 -0400
Received: by bwz19 with SMTP id 19so53128bwz.21
        for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 15:35:57 -0700 (PDT)
In-Reply-To: <201004112338.47019.nuclearcat@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 11 avril 2010 =C3=A0 23:38 +0300, Denys Fedorysychenko a =C3=
=A9crit :
> Hi
>=20
> Got recently NULL pointer dereference
> Note - it seems in 32-bit i didn't experience this issue.
>=20
> Router with NAT, HFSC shapers terminated with bfifo qdiscs (some atta=
ched to=20
> 802.1Q vlan's), userspace application using tun.
> Hardware - network cards e1000e, Core 2 based architecture (two Quad =
Xeon),=20
>=20
> full message received over netconsole attached
> More info can provide on request
> pi=C3=A8ce jointe document texte brut (BUG)
> Apr 11 23:28:52 ROUTER kernel: [21095.453138] BUG: unable to handle k=
ernel NULL pointer dereference at (null)
> Apr 11 23:28:52 ROUTER kernel: [21095.453334] IP: [<ffffffff811e5877>=
] dev_queue_xmit+0x284/0x465
> Apr 11 23:28:52 ROUTER kernel: [21095.453522] PGD 20b247067 PUD 20b24=
c067 PMD 0=20
> Apr 11 23:28:52 ROUTER kernel: [21095.453704] Oops: 0000 [#1] SMP=20
> Apr 11 23:28:52 ROUTER kernel: [21095.453880] last sysfs file: /sys/d=
evices/virtual/misc/tun/dev
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] CPU 0=20
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] Pid: 2864, comm: globax=
 Not tainted 2.6.33.2-build-0051-64 #4         /       =20
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] RIP: 0010:[<ffffffff811=
e5877>]  [<ffffffff811e5877>] dev_queue_xmit+0x284/0x465
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] RSP: 0000:ffff880028203=
db0  EFLAGS: 00010202
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] RAX: 0000000000002000 R=
BX: 0000000000000000 RCX: ffff8802087d8d00
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] RDX: ffff88021d818000 R=
SI: 0000000000000000 RDI: ffff8802135850e8
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] RBP: ffff880028203de0 R=
08: ffff88021c01d89c R09: ffff88021c01dc00
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] R10: dead000000200200 R=
11: dead000000100100 R12: ffff88021e212b80
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] R13: ffff88021da51e80 R=
14: ffff8802135850e8 R15: ffff88021be62000
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] FS:  0000000000000000(0=
000) GS:ffff880028200000(0063) knlGS:00000000f7e51b10
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] CS:  0010 DS: 002b ES: =
002b CR0: 0000000080050033
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] CR2: 0000000000000000 C=
R3: 000000020b248000 CR4: 00000000000006f0
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] DR0: 0000000000000000 D=
R1: 0000000000000000 DR2: 0000000000000000
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] DR3: 0000000000000000 D=
R6: 00000000ffff0ff0 DR7: 0000000000000400
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] Process globax (pid: 28=
64, threadinfo ffff8802118c0000, task ffff8802182c2c20)
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] Stack:
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  ffff88021d818000 ffff8=
8021da51e80 0000000000000042 ffff88021da51e80
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] <0> ffff88021be62000 ff=
ff88021be62000 ffff880028203e00 ffffffffa01c12a9
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] <0> 0000000000000000 ff=
ff8802135850e8 ffff880028203e50 ffffffff811e540e
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] Call Trace:
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  <IRQ>=20
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffffa01c12a9>] v=
lan_dev_hwaccel_hard_start_xmit+0x68/0x86 [8021q]
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff811e540e>] d=
ev_hard_start_xmit+0x232/0x304
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff811f6482>] s=
ch_direct_xmit+0x5d/0x16b
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff811f664c>] _=
_qdisc_run+0xbc/0xdc
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff811e2c89>] n=
et_tx_action+0xc2/0x120
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff81039670>] _=
_do_softirq+0x96/0x11a
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff810037cc>] c=
all_softirq+0x1c/0x28
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff81005543>] d=
o_softirq+0x33/0x68
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff81039407>] i=
rq_exit+0x36/0x75
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff81016f63>] s=
mp_apic_timer_interrupt+0x88/0x96
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  [<ffffffff81003293>] a=
pic_timer_interrupt+0x13/0x20
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  <EOI>
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] Code: e2=20

> 48 8b 55 d0 // mov    -0x30(%rbp),%rdx

> 49 c1 e4 07 // shl    $0x7,%r12=20

>  66 41 8b 86 a6 00 00 00 // mov 0xa6(%r14),%ax

> 4c 03 a2 00 03 00 00 // add 0x0300(%rdx),%r12

> 80 e4 cf  // and    $0xcf,%ah=20

> 80 cc 20 // or     $0x20,%ah

> 49 8b 5c 24 08 // mov    0x8(%r12),%rbx   rcu_dereference(txq->qdisc)=
;

> 66 41 89 86 a6 00 00 00 // mov    %ax,0xa6(%r14)=20

> <48> 83 3b 00 // cmpq   $0x0,(%rbx)

> 0f 84 bb 00 00 00 // je ...

>  4c 8d ab 9c 00 00 00 4c 89 ef e8
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] RIP  [<ffffffff811e5877=
>] dev_queue_xmit+0x284/0x465
> Apr 11 23:28:52 ROUTER kernel: [21095.454001]  RSP <ffff880028203db0>
> Apr 11 23:28:52 ROUTER kernel: [21095.454001] CR2: 0000000000000000
> Apr 11 23:28:52 ROUTER kernel: [21095.462975] ---[ end trace 2421d995=
c1afd7c3 ]---
> Apr 11 23:28:52 ROUTER kernel: [21095.463199] Kernel panic - not sync=
ing: Fatal exception in interrupt
> Apr 11 23:28:52 ROUTER kernel: [21095.463428] Pid: 2864, comm: globax=
 Tainted: G      D    2.6.33.2-build-0051-64 #4
> Apr 11 23:28:52 ROUTER kernel: [21095.463819] Call Trace:
> Apr 11 23:28:52 ROUTER kernel: [21095.464036]  <IRQ>  [<ffffffff81259=
743>] panic+0xa0/0x161
> Apr 11 23:28:52 ROUTER kernel: [21095.464307]  [<ffffffff81003293>] ?=
 apic_timer_interrupt+0x13/0x20
> Apr 11 23:28:52 ROUTER kernel: [21095.464533]  [<ffffffff81035673>] ?=
 kmsg_dump+0x112/0x12c
> Apr 11 23:28:52 ROUTER kernel: [21095.464757]  [<ffffffff81006651>] o=
ops_end+0xaa/0xba
> Apr 11 23:28:52 ROUTER kernel: [21095.464980]  [<ffffffff8101e653>] n=
o_context+0x1f3/0x202
> Apr 11 23:28:52 ROUTER kernel: [21095.465211]  [<ffffffff810523a4>] ?=
 tick_program_event+0x25/0x27
> Apr 11 23:28:52 ROUTER kernel: [21095.465437]  [<ffffffff8101e81c>] _=
_bad_area_nosemaphore+0x1ba/0x1e0
> Apr 11 23:28:52 ROUTER kernel: [21095.465668]  [<ffffffff8113f8b3>] ?=
 swiotlb_map_page+0x0/0xd5
> Apr 11 23:28:52 ROUTER kernel: [21095.465907]  [<ffffffffa015c55a>] ?=
 pci_map_single+0x8a/0x99 [e1000e]
> Apr 11 23:28:52 ROUTER kernel: [21095.466139]  [<ffffffff8113f0c0>] ?=
 swiotlb_dma_mapping_error+0x18/0x25
> Apr 11 23:28:52 ROUTER kernel: [21095.466372]  [<ffffffffa015a2e0>] ?=
 pci_dma_mapping_error+0x31/0x3d [e1000e]
> Apr 11 23:28:52 ROUTER kernel: [21095.466605]  [<ffffffffa015cc37>] ?=
 e1000_xmit_frame+0x6ce/0xa43 [e1000e]
> Apr 11 23:28:52 ROUTER kernel: [21095.466833]  [<ffffffff8101e850>] b=
ad_area_nosemaphore+0xe/0x10
> Apr 11 23:28:52 ROUTER kernel: [21095.467064]  [<ffffffff8101eb32>] d=
o_page_fault+0x114/0x24a
> Apr 11 23:28:52 ROUTER kernel: [21095.467293]  [<ffffffff8125bc9f>] p=
age_fault+0x1f/0x30
> Apr 11 23:28:52 ROUTER kernel: [21095.467516]  [<ffffffff811e5877>] ?=
 dev_queue_xmit+0x284/0x465
> Apr 11 23:28:52 ROUTER kernel: [21095.467743]  [<ffffffffa01c12a9>] v=
lan_dev_hwaccel_hard_start_xmit+0x68/0x86 [8021q]
> Apr 11 23:28:52 ROUTER kernel: [21095.468139]  [<ffffffff811e540e>] d=
ev_hard_start_xmit+0x232/0x304
> Apr 11 23:28:52 ROUTER kernel: [21095.468366]  [<ffffffff811f6482>] s=
ch_direct_xmit+0x5d/0x16b
> Apr 11 23:28:52 ROUTER kernel: [21095.468591]  [<ffffffff811f664c>] _=
_qdisc_run+0xbc/0xdc
> Apr 11 23:28:52 ROUTER kernel: [21095.468814]  [<ffffffff811e2c89>] n=
et_tx_action+0xc2/0x120
> Apr 11 23:28:52 ROUTER kernel: [21095.469042]  [<ffffffff81039670>] _=
_do_softirq+0x96/0x11a
> Apr 11 23:28:52 ROUTER kernel: [21095.469267]  [<ffffffff810037cc>] c=
all_softirq+0x1c/0x28
> Apr 11 23:28:52 ROUTER kernel: [21095.469491]  [<ffffffff81005543>] d=
o_softirq+0x33/0x68
> Apr 11 23:28:52 ROUTER kernel: [21095.469714]  [<ffffffff81039407>] i=
rq_exit+0x36/0x75
> Apr 11 23:28:52 ROUTER kernel: [21095.469936]  [<ffffffff81016f63>] s=
mp_apic_timer_interrupt+0x88/0x96
> Apr 11 23:28:52 ROUTER kernel: [21095.470167]  [<ffffffff81003293>] a=
pic_timer_interrupt+0x13/0x20

Hi Denys !

txq->qdisc is NULL at this point, I dont think its even possible, so my
random guess is dev_pick_tx() got an queue_index >
dev->real_num_tx_queues


        txq =3D dev_pick_tx(dev, skb);
        q =3D rcu_dereference(txq->qdisc);  // q =3D NULL

#ifdef CONFIG_NET_CLS_ACT
        skb->tc_verd =3D SET_TC_AT(skb->tc_verd, AT_EGRESS);
#endif
        if (q->enqueue) {  // crash in dereference
                rc =3D __dev_xmit_skb(skb, q, dev, txq);
                goto out;
        }


I believe the following lines from dev_pick_tx() are not the problem :

	if (sk && sk->sk_dst_cache)=20
		sk_tx_queue_set(sk, queue_index);

It is IMHO not safe, because route for this socket might have just
changed and we are transmitting an old packet (queued some milli second=
s
before, when route was different).

We then memorize a queue_index that might be too big for the new device
of new selected route.

Next packet we want to transmit will take the cached value of
queue_index, correct for old device, maybe not correct for new device.

You could try to revert commit a4ee3ce3293dc931fab19beb472a8bde1295aebe

commit a4ee3ce3293dc931fab19beb472a8bde1295aebe
Author: Krishna Kumar <krkumar2@in.ibm.com>
Date:   Mon Oct 19 23:50:07 2009 +0000

    net: Use sk_tx_queue_mapping for connected sockets
   =20
    For connected sockets, the first run of dev_pick_tx saves the
    calculated txq in sk_tx_queue_mapping. This is not saved if
    either the device has a queue select or the socket is not
    connected. Next iterations of dev_pick_tx uses the cached value
    of sk_tx_queue_mapping.
   =20
    Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 28b0b9e..fa88dcd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1791,13 +1791,25 @@ EXPORT_SYMBOL(skb_tx_hash);
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
-	const struct net_device_ops *ops =3D dev->netdev_ops;
-	u16 queue_index =3D 0;
+	u16 queue_index;
+	struct sock *sk =3D skb->sk;
+
+	if (sk_tx_queue_recorded(sk)) {
+		queue_index =3D sk_tx_queue_get(sk);
+	} else {
+		const struct net_device_ops *ops =3D dev->netdev_ops;
=20
-	if (ops->ndo_select_queue)
-		queue_index =3D ops->ndo_select_queue(dev, skb);
-	else if (dev->real_num_tx_queues > 1)
-		queue_index =3D skb_tx_hash(dev, skb);
+		if (ops->ndo_select_queue) {
+			queue_index =3D ops->ndo_select_queue(dev, skb);
+		} else {
+			queue_index =3D 0;
+			if (dev->real_num_tx_queues > 1)
+				queue_index =3D skb_tx_hash(dev, skb);
+
+			if (sk && sk->sk_dst_cache)
+				sk_tx_queue_set(sk, queue_index);
+		}
+	}
=20
 	skb_set_queue_mapping(skb, queue_index);
 	return netdev_get_tx_queue(dev, queue_index);



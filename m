From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel paging request at 000041ed00000001
Date: Mon, 14 Jun 2010 10:31:35 +0200
Message-ID: <1276504295.2478.35.camel@edumazet-laptop>
References: <9D7251E7-0EFD-4645-BC30-A96191D1046E@res.lt>
	 <1276185609.2448.12.camel@edumazet-laptop>
	 <80C864F3-B075-4E3A-B72E-6FCD945A8058@res.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Arturas <arturasl@res.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59248 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988Ab0FNIbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 04:31:40 -0400
Received: by wyb40 with SMTP id 40so3550775wyb.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 01:31:38 -0700 (PDT)
In-Reply-To: <80C864F3-B075-4E3A-B72E-6FCD945A8058@res.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 juin 2010 =C3=A0 10:05 +0300, Arturas a =C3=A9crit :
> Hi,
>=20
> your patch fixes hangs and i get a warning (see bellow if needed) whe=
n it triggers.=20
> As I understand it is workaround and a real fix should be different?=20
> What about bonding to be multiqueue aware?
>=20

But your problem is about bridge, not bonding (see trace).

And 2.6.34 wont accept such changes, its already released.

> I also have another issue with NMI. On older machine with 5500 xeons =
i=20
> have almost no overhead with nmi_watchdog enabled, but on this it is =
about twice.
> without nmi enabled cpu peak average is 30%, and with nmi enabled i h=
ave 53%.
> When traffic is not passing all cpus are idling at 100%.
> Maybe overhead could be a little bit smaller? :-)
>=20

I am a bit lost here, NMI have litle to do with network stack ;)


> [ 8064.562106] WARNING: at net/core/dev.c:1964 dev_queue_xmit+0x504/0=
x520()
> [ 8064.562108] Hardware name: S5520UR
> [ 8064.562108] br0
> [ 8064.562109] Modules linked in: ipt_REDIRECT xt_tcpudp ipt_set ipta=
ble_filter iptable_nat nf_nat ipt_addrtype xt_dscp xt_string xt_owner x=
t_multiport xt_mark xt_iprange xt_hashlimit xt_conntrack xt_connmark xt=
_DSCP xt_NFQUEUE xt_MARK xt_CONNMARK ip_tables x_tables ip_set_ipmap ip=
_set cls_u32 sch_htb ipmi_watchdog ipmi_devintf ipmi_si ipmi_msghandler=
 nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack bonding ipv6 ixgbe igb m=
dio
> [ 8064.562125] Pid: 8643, comm: lighttpd Not tainted 2.6.34-gentoo #6
> [ 8064.562126] Call Trace:
> [ 8064.562133]  [<ffffffff8103e463>] ? warn_slowpath_common+0x73/0xb0
> [ 8064.562135]  [<ffffffff8103e500>] ? warn_slowpath_fmt+0x40/0x50
> [ 8064.562137]  [<ffffffff812f47b4>] ? dev_queue_xmit+0x504/0x520
> [ 8064.562141]  [<ffffffff813222d2>] ? ip_queue_xmit+0x182/0x3e0
> [ 8064.562145]  [<ffffffff81335c1e>] ? tcp_init_tso_segs+0x2e/0x50
> [ 8064.562147]  [<ffffffff81338bb5>] ? tcp_write_xmit+0x75/0xa00
> [ 8064.562151]  [<ffffffff810494f3>] ? lock_timer_base+0x33/0x70
> [ 8064.562153]  [<ffffffff8133665c>] ? tcp_transmit_skb+0x3ac/0x820
> [ 8064.562155]  [<ffffffff8132bd76>] ? tcp_sendmsg+0x866/0xbf0
> [ 8064.562156]  [<ffffffff81338d2c>] ? tcp_write_xmit+0x1ec/0xa00
> [ 8064.562161]  [<ffffffff812e5f7d>] ? lock_sock_nested+0x3d/0xe0
> [ 8064.562163]  [<ffffffff812e0ff0>] ? sock_aio_write+0x0/0x150
> [ 8064.562166]  [<ffffffff81339599>] ? __tcp_push_pending_frames+0x19=
/0x80
> [ 8064.562167]  [<ffffffff8132a3fa>] ? do_tcp_setsockopt+0x53a/0x690
> [ 8064.562171]  [<ffffffff810bc439>] ? do_sync_readv_writev+0xa9/0xf0
> [ 8064.562173]  [<ffffffff810494f3>] ? lock_timer_base+0x33/0x70
> [ 8064.562174]  [<ffffffff810bc63f>] ? do_sync_read+0xbf/0x100
> [ 8064.562176]  [<ffffffff810bcb82>] ? do_readv_writev+0x172/0x220
> [ 8064.562179]  [<ffffffff810cdc3f>] ? d_kill+0x5f/0x80
> [ 8064.562181]  [<ffffffff810ce3f8>] ? dput+0xb8/0x180
> [ 8064.562183]  [<ffffffff812e1ef2>] ? sockfd_lookup_light+0x22/0x80
> [ 8064.562185]  [<ffffffff812e248d>] ? sys_setsockopt+0x6d/0xd0
> [ 8064.562188]  [<ffffffff81002502>] ? system_call_fastpath+0x16/0x1b
>=20


Could you please test another patch ?

Before calling sk_tx_queue_set(sk, queue_index); we should check if dst
dev is current device.

--- net/core/dev.c.orig	2010-06-10 17:52:17.000000000 +0200
+++ net/core/dev.c	2010-06-14 10:25:25.000000000 +0200
@@ -1958,12 +1958,10 @@
 static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_in=
dex)
 {
 	if (unlikely(queue_index >=3D dev->real_num_tx_queues)) {
-		if (net_ratelimit()) {
-			WARN(1, "%s selects TX queue %d, but "
-			     "real number of TX queues is %d\n",
-			     dev->name, queue_index,
-			     dev->real_num_tx_queues);
-		}
+		WARN_ONCE("%s selects TX queue %d, but "
+			  "real number of TX queues is %d\n",
+			  dev->name, queue_index,
+			  dev->real_num_tx_queues);
 		return 0;
 	}
 	return queue_index;
@@ -1977,6 +1975,7 @@
=20
 	if (sk_tx_queue_recorded(sk)) {
 		queue_index =3D sk_tx_queue_get(sk);
+		queue_index =3D dev_cap_txqueue(dev, queue_index);
 	} else {
 		const struct net_device_ops *ops =3D dev->netdev_ops;
=20
@@ -1991,7 +1990,7 @@
 			if (sk) {
 				struct dst_entry *dst =3D rcu_dereference_bh(sk->sk_dst_cache);
=20
-				if (dst && skb_dst(skb) =3D=3D dst)
+				if (dst && skb_dst(skb) =3D=3D dst && dst->dev =3D=3D dev)
 					sk_tx_queue_set(sk, queue_index);
 			}
 		}



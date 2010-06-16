From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Wed, 16 Jun 2010 04:58:59 +0200
Message-ID: <1276657139.19249.50.camel@edumazet-laptop>
References: <20100610145915.721a86b7@nehalam>
	 <20100610224839.GA22469@gondor.apana.org.au>
	 <20100611021142.GA24490@gondor.apana.org.au>
	 <20100615.113940.245399246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, shemminger@vyatta.com, mst@redhat.com,
	frzhang@redhat.com, netdev@vger.kernel.org, amwang@redhat.com,
	mpm@selenic.com
To: David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39247 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861Ab0FPC7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 22:59:05 -0400
Received: by wyb40 with SMTP id 40so5322099wyb.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 19:59:03 -0700 (PDT)
In-Reply-To: <20100615.113940.245399246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 juin 2010 =C3=A0 11:39 -0700, David Miller a =C3=A9crit :
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 11 Jun 2010 12:11:42 +1000
>=20
> > On Fri, Jun 11, 2010 at 08:48:39AM +1000, Herbert Xu wrote:
> >> On Thu, Jun 10, 2010 at 02:59:15PM -0700, Stephen Hemminger wrote:
> >> >
> >> > Okay, then add a comment where in_irq is used?
> >>=20
> >> Actually let me put it into a wrapper.  I'll respin the patches.
> >=20
> > OK here is a repost.  And this time it really is 8 patches :)
> > I've tested it lightly.
>=20
> All applied to net-next-2.6, thanks Herbert.

Well...

[   52.914014] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
[   52.914018] [ INFO: suspicious rcu_dereference_check() usage. ]
[   52.914020] ---------------------------------------------------
[   52.914024] include/linux/netpoll.h:67 invoked rcu_dereference_check=
() without protection!
[   52.914027]=20
[   52.914027] other info that might help us debug this:
[   52.914029]=20
[   52.914031]=20
[   52.914032] rcu_scheduler_active =3D 1, debug_locks =3D 1
[   52.914035] 4 locks held by swapper/0:
[   52.914037]  #0:  (&n->timer){+.-...}, at: [<c103fd95>] run_timer_so=
ftirq+0x1b8/0x419
[   52.914052]  #1:  (slock-AF_INET){+.....}, at: [<c12f2b3d>] icmp_sen=
d+0x149/0x58b
[   52.914063]  #2:  (rcu_read_lock_bh){.+....}, at: [<c129978d>] dev_q=
ueue_xmit+0xf7/0x5df
[   52.914073]  #3:  (rcu_read_lock_bh){.+....}, at: [<c12977ae>] netif=
_rx+0x0/0x195
[   52.914081]=20
[   52.914081] stack backtrace:
[   52.914086] Pid: 0, comm: swapper Not tainted 2.6.35-rc1-00508-gdbe3=
a24-dirty #78
[   52.914089] Call Trace:
[   52.914095]  [<c132cf0c>] ? printk+0xf/0x13
[   52.914103]  [<c1059ac6>] lockdep_rcu_dereference+0x74/0x7d
[   52.914107]  [<c1297819>] netif_rx+0x6b/0x195
[   52.914111]  [<c129978d>] ? dev_queue_xmit+0xf7/0x5df
[   52.914117]  [<c1240775>] loopback_xmit+0x4a/0x70
[   52.914122]  [<c12995cf>] dev_hard_start_xmit+0x25b/0x322
[   52.914126]  [<c1299b5b>] dev_queue_xmit+0x4c5/0x5df
[   52.914131]  [<c105ccf7>] ? trace_hardirqs_on+0xb/0xd
[   52.914135]  [<c129f611>] neigh_resolve_output+0x2e8/0x33f
[   52.914142]  [<c12a8b2a>] ? eth_header+0x0/0x8e
[   52.914147]  [<c12d3dbb>] ip_finish_output+0x323/0x3b1
[   52.914152]  [<c103955f>] ? local_bh_enable_ip+0x97/0xad
[   52.914156]  [<c12d485d>] ip_output+0xe2/0xfe
[   52.914160]  [<c12d3ff5>] ip_local_out+0x41/0x55
[   52.914164]  [<c12d5755>] ip_push_pending_frames+0x284/0x2fa
[   52.914169]  [<c12f218d>] icmp_push_reply+0xe8/0xf3
[   52.914174]  [<c12f2f36>] icmp_send+0x542/0x58b
[   52.914181]  [<c102b6af>] ? find_busiest_group+0x1c9/0x631
[   52.914188]  [<c12cb280>] ipv4_link_failure+0x17/0x7b
[   52.914193]  [<c12f0841>] arp_error_report+0x46/0x61
[   52.914197]  [<c129f8e0>] neigh_invalidate+0x68/0x80
[   52.914201]  [<c12a0bef>] neigh_timer_handler+0x124/0x1d2
[   52.914206]  [<c103fe7b>] run_timer_softirq+0x29e/0x419
[   52.914210]  [<c12a0acb>] ? neigh_timer_handler+0x0/0x1d2
[   52.914215]  [<c1039a21>] __do_softirq+0x126/0x277
[   52.914219]  [<c10398fb>] ? __do_softirq+0x0/0x277
[   52.914222]  <IRQ>  [<c1039c0d>] ? irq_exit+0x38/0x74
[   52.914230]  [<c1003d1f>] ? do_IRQ+0x87/0x9b
[   52.914235]  [<c1002d2e>] ? common_interrupt+0x2e/0x34
[   52.914241]  [<c105007b>] ? sched_clock_local+0x3f/0x11f
[   52.914249]  [<c11ba45b>] ? acpi_idle_enter_bm+0x271/0x2a0
[   52.914256]  [<c12797bd>] ? cpuidle_idle_call+0x76/0x151
[   52.914261]  [<c1001565>] ? cpu_idle+0x49/0x76
[   52.914266]  [<c1319ece>] ? rest_init+0xd6/0xdb
[   52.914274]  [<c156579f>] ? start_kernel+0x31b/0x320
[   52.914278]  [<c15650c9>] ? i386_start_kernel+0xc9/0xd0


Paul, could you please explain if current lockdep rules are correct, or=
 could be relaxed ?

I thought :

rcu_read_lock_bh();

was a shorthand to

local_disable_bh();
rcu_read_lock();

Why lockdep is not able to make a correct diagnostic ?

Thanks

[PATCH net-next-2.6] netpoll: Fix one rcu_dereference() lockdep splat

lockdep doesnt allow yet following  construct :

rcu_read_lock_bh();
npinfo =3D rcu_dereference(skb->dev->npinfo);

=46ix lockdep splat using rcu_dereference_bh()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netpoll.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 4c77fe7..472365e 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -64,7 +64,7 @@ static inline bool netpoll_rx(struct sk_buff *skb)
 	bool ret =3D false;
=20
 	rcu_read_lock_bh();
-	npinfo =3D rcu_dereference(skb->dev->npinfo);
+	npinfo =3D rcu_dereference_bh(skb->dev->npinfo);
=20
 	if (!npinfo || (list_empty(&npinfo->rx_np) && !npinfo->rx_flags))
 		goto out;



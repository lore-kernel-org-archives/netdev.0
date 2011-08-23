From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: (3.1.0-rc2-git7) include/linux/inetdevice.h:209 invoked
 rcu_dereference_check() without protection!
Date: Tue, 23 Aug 2011 07:32:42 +0200
Message-ID: <1314077562.4791.21.camel@edumazet-laptop>
References: <20110823024423.GA23874@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49398 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094Ab1HWFct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 01:32:49 -0400
Received: by wwf5 with SMTP id 5so5881934wwf.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 22:32:47 -0700 (PDT)
In-Reply-To: <20110823024423.GA23874@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 ao=C3=BBt 2011 =C3=A0 22:44 -0400, Dave Jones a =C3=A9crit =
:
> Just hit this..
> Is the fix as straight forward as changing that __in_dev_get_rcu to
> an in_dev_get() ?
>=20
> 	Dave
>=20
>=20
>  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
>  [ INFO: suspicious rcu_dereference_check() usage. ]
>  ---------------------------------------------------
>  include/linux/inetdevice.h:209 invoked rcu_dereference_check() witho=
ut protection!
> =20
>  other info that might help us debug this:
> =20
>=20
>  rcu_scheduler_active =3D 1, debug_locks =3D 0
>  4 locks held by setfiles/2123:
>   #0:  (&sb->s_type->i_mutex_key#13){+.+.+.}, at: [<ffffffff8114cbc4>=
] walk_component+0x1ef/0x3e8
>   #1:  (&isec->lock){+.+.+.}, at: [<ffffffff81204bca>] inode_doinit_w=
ith_dentry+0x3f/0x41f
>   #2:  (&tbl->proxy_timer){+.-...}, at: [<ffffffff8106a803>] run_time=
r_softirq+0x157/0x372
>   #3:  (class){+.-...}, at: [<ffffffff8141f256>] neigh_proxy_process+=
0x36/0x103
> =20
>  stack backtrace:
>  Pid: 2123, comm: setfiles Tainted: G        W   3.1.0-0.rc2.git7.2.f=
c16.x86_64 #1
>  Call Trace:
>   <IRQ>  [<ffffffff8108ca23>] lockdep_rcu_dereference+0xa7/0xaf
>   [<ffffffff8146a0b7>] __in_dev_get_rcu+0x55/0x5d
>   [<ffffffff8146a751>] arp_process+0x25/0x4d7
>   [<ffffffff8146ac11>] parp_redo+0xe/0x10
>   [<ffffffff8141f2ba>] neigh_proxy_process+0x9a/0x103
>   [<ffffffff8106a8c4>] run_timer_softirq+0x218/0x372
>   [<ffffffff8106a803>] ? run_timer_softirq+0x157/0x372
>   [<ffffffff8141f220>] ? neigh_stat_seq_open+0x41/0x41
>   [<ffffffff8108f2f0>] ? mark_held_locks+0x6d/0x95
>   [<ffffffff81062bb6>] __do_softirq+0x112/0x25a
>   [<ffffffff8150d27c>] call_softirq+0x1c/0x30
>   [<ffffffff81010bf5>] do_softirq+0x4b/0xa2
>   [<ffffffff81062f65>] irq_exit+0x5d/0xcf
>   [<ffffffff8150dc11>] smp_apic_timer_interrupt+0x7c/0x8a
>   [<ffffffff8150baf3>] apic_timer_interrupt+0x73/0x80
>   <EOI>  [<ffffffff8108f439>] ? trace_hardirqs_on_caller+0x121/0x158
>   [<ffffffff814fc285>] ? __slab_free+0x30/0x24c
>   [<ffffffff814fc283>] ? __slab_free+0x2e/0x24c
>   [<ffffffff81204e74>] ? inode_doinit_with_dentry+0x2e9/0x41f
>   [<ffffffff81204e74>] ? inode_doinit_with_dentry+0x2e9/0x41f
>   [<ffffffff81204e74>] ? inode_doinit_with_dentry+0x2e9/0x41f
>   [<ffffffff81130cb0>] kfree+0x108/0x131
>   [<ffffffff81204e74>] inode_doinit_with_dentry+0x2e9/0x41f
>   [<ffffffff81204fc6>] selinux_d_instantiate+0x1c/0x1e
>   [<ffffffff81200f4f>] security_d_instantiate+0x21/0x23
>   [<ffffffff81154625>] d_instantiate+0x5c/0x61
>   [<ffffffff811563ca>] d_splice_alias+0xbc/0xd2
>   [<ffffffff811b17ff>] ext4_lookup+0xba/0xeb
>   [<ffffffff8114bf1e>] d_alloc_and_lookup+0x45/0x6b
>   [<ffffffff8114cbea>] walk_component+0x215/0x3e8
>   [<ffffffff8114cdf8>] lookup_last+0x3b/0x3d
>   [<ffffffff8114daf3>] path_lookupat+0x82/0x2af
>   [<ffffffff8110fc53>] ? might_fault+0xa5/0xac
>   [<ffffffff8110fc0a>] ? might_fault+0x5c/0xac
>   [<ffffffff8114c564>] ? getname_flags+0x31/0x1ca
>   [<ffffffff8114dd48>] do_path_lookup+0x28/0x97
>   [<ffffffff8114df2c>] user_path_at+0x59/0x96
>   [<ffffffff811467ad>] ? cp_new_stat+0xf7/0x10d
>   [<ffffffff811469a6>] vfs_fstatat+0x44/0x6e
>   [<ffffffff811469ee>] vfs_lstat+0x1e/0x20
>   [<ffffffff81146b3d>] sys_newlstat+0x1a/0x33
>   [<ffffffff8108f439>] ? trace_hardirqs_on_caller+0x121/0x158
>   [<ffffffff812535fe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>   [<ffffffff8150af82>] system_call_fastpath+0x16/0x1b
>=20

Dave, thanks again for your report, here the fix I cooked to address
this.

Kernels >=3D 2.6.36 are affected, probably only RT ones, since
neigh_proxy_process() holds a spinlock before the call to proxy_redo().

David, IPv6 side is affected too only in net-next, but following patch
should take care of both protocols.

Thanks

[PATCH] arp: fix rcu lockdep splat in arp_process()

Dave Jones reported a lockdep splat triggered by an arp_process() call
from parp_redo().

Commit faa9dcf793be (arp: RCU changes) is the origin of the bug, since
it assumed arp_process() was called under rcu_read_lock(), which is not
true in this particular path.

Instead of adding rcu_read_lock() in parp_redo(), I chose to add it in=20
neigh_proxy_process() to take care of IPv6 side too.

 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
 [ INFO: suspicious rcu_dereference_check() usage. ]
 ---------------------------------------------------
 include/linux/inetdevice.h:209 invoked rcu_dereference_check() without
protection!
=20
 other info that might help us debug this:
=20
=20
 rcu_scheduler_active =3D 1, debug_locks =3D 0
 4 locks held by setfiles/2123:
  #0:  (&sb->s_type->i_mutex_key#13){+.+.+.}, at: [<ffffffff8114cbc4>]
walk_component+0x1ef/0x3e8
  #1:  (&isec->lock){+.+.+.}, at: [<ffffffff81204bca>]
inode_doinit_with_dentry+0x3f/0x41f
  #2:  (&tbl->proxy_timer){+.-...}, at: [<ffffffff8106a803>]
run_timer_softirq+0x157/0x372
  #3:  (class){+.-...}, at: [<ffffffff8141f256>] neigh_proxy_process
+0x36/0x103
=20
 stack backtrace:
 Pid: 2123, comm: setfiles Tainted: G        W
3.1.0-0.rc2.git7.2.fc16.x86_64 #1
 Call Trace:
  <IRQ>  [<ffffffff8108ca23>] lockdep_rcu_dereference+0xa7/0xaf
  [<ffffffff8146a0b7>] __in_dev_get_rcu+0x55/0x5d
  [<ffffffff8146a751>] arp_process+0x25/0x4d7
  [<ffffffff8146ac11>] parp_redo+0xe/0x10
  [<ffffffff8141f2ba>] neigh_proxy_process+0x9a/0x103
  [<ffffffff8106a8c4>] run_timer_softirq+0x218/0x372
  [<ffffffff8106a803>] ? run_timer_softirq+0x157/0x372
  [<ffffffff8141f220>] ? neigh_stat_seq_open+0x41/0x41
  [<ffffffff8108f2f0>] ? mark_held_locks+0x6d/0x95
  [<ffffffff81062bb6>] __do_softirq+0x112/0x25a
  [<ffffffff8150d27c>] call_softirq+0x1c/0x30
  [<ffffffff81010bf5>] do_softirq+0x4b/0xa2
  [<ffffffff81062f65>] irq_exit+0x5d/0xcf
  [<ffffffff8150dc11>] smp_apic_timer_interrupt+0x7c/0x8a
  [<ffffffff8150baf3>] apic_timer_interrupt+0x73/0x80
  <EOI>  [<ffffffff8108f439>] ? trace_hardirqs_on_caller+0x121/0x158
  [<ffffffff814fc285>] ? __slab_free+0x30/0x24c
  [<ffffffff814fc283>] ? __slab_free+0x2e/0x24c
  [<ffffffff81204e74>] ? inode_doinit_with_dentry+0x2e9/0x41f
  [<ffffffff81204e74>] ? inode_doinit_with_dentry+0x2e9/0x41f
  [<ffffffff81204e74>] ? inode_doinit_with_dentry+0x2e9/0x41f
  [<ffffffff81130cb0>] kfree+0x108/0x131
  [<ffffffff81204e74>] inode_doinit_with_dentry+0x2e9/0x41f
  [<ffffffff81204fc6>] selinux_d_instantiate+0x1c/0x1e
  [<ffffffff81200f4f>] security_d_instantiate+0x21/0x23
  [<ffffffff81154625>] d_instantiate+0x5c/0x61
  [<ffffffff811563ca>] d_splice_alias+0xbc/0xd2
  [<ffffffff811b17ff>] ext4_lookup+0xba/0xeb
  [<ffffffff8114bf1e>] d_alloc_and_lookup+0x45/0x6b
  [<ffffffff8114cbea>] walk_component+0x215/0x3e8
  [<ffffffff8114cdf8>] lookup_last+0x3b/0x3d
  [<ffffffff8114daf3>] path_lookupat+0x82/0x2af
  [<ffffffff8110fc53>] ? might_fault+0xa5/0xac
  [<ffffffff8110fc0a>] ? might_fault+0x5c/0xac
  [<ffffffff8114c564>] ? getname_flags+0x31/0x1ca
  [<ffffffff8114dd48>] do_path_lookup+0x28/0x97
  [<ffffffff8114df2c>] user_path_at+0x59/0x96
  [<ffffffff811467ad>] ? cp_new_stat+0xf7/0x10d
  [<ffffffff811469a6>] vfs_fstatat+0x44/0x6e
  [<ffffffff811469ee>] vfs_lstat+0x1e/0x20
  [<ffffffff81146b3d>] sys_newlstat+0x1a/0x33
  [<ffffffff8108f439>] ? trace_hardirqs_on_caller+0x121/0x158
  [<ffffffff812535fe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
  [<ffffffff8150af82>] system_call_fastpath+0x16/0x1b


Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/neighbour.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8fab9b0..1334d7e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1319,11 +1319,15 @@ static void neigh_proxy_process(unsigned long a=
rg)
=20
 		if (tdif <=3D 0) {
 			struct net_device *dev =3D skb->dev;
+
 			__skb_unlink(skb, &tbl->proxy_queue);
-			if (tbl->proxy_redo && netif_running(dev))
+			if (tbl->proxy_redo && netif_running(dev)) {
+				rcu_read_lock();
 				tbl->proxy_redo(skb);
-			else
+				rcu_read_unlock();
+			} else {
 				kfree_skb(skb);
+			}
=20
 			dev_put(dev);
 		} else if (!sched_next || tdif < sched_next)



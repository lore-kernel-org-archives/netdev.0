From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from
 uninitialized memory in __alloc_skb
Date: Wed, 20 Apr 2011 12:02:45 +0200
Message-ID: <1303293765.3186.74.camel@edumazet-laptop>
References: <bug-33502-10286@https.bugzilla.kernel.org/>
	 <20110418153852.153d3ed3.akpm@linux-foundation.org>
	 <1303181466.4152.39.camel@edumazet-laptop>
	 <1303182557.4152.48.camel@edumazet-laptop>
	 <1303183217.4152.49.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1104191210011.17888@router.home>
	 <1303244270.2756.3.camel@edumazet-laptop> <4DAE7579.3020400@cs.helsinki.fi>
	 <1303279470.2756.17.camel@edumazet-laptop>
	 <1303285519.4dae8f0fdf9b1@imp.free.fr>  <4DAE901C.2090809@cs.helsinki.fi>
	 <1303286998.3186.18.camel@edumazet-laptop>
	 <1303290464.3186.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: casteyde.christian@free.fr, Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Vegard Nossum <vegardno@ifi.uio.no>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53389 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696Ab1DTKCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 06:02:50 -0400
Received: by wwa36 with SMTP id 36so680927wwa.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2011 03:02:49 -0700 (PDT)
In-Reply-To: <1303290464.3186.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 avril 2011 =C3=A0 11:07 +0200, Eric Dumazet a =C3=A9crit=
 :
> I had one splat (before applying any patch), adding CONFIG_PREEMPT to=
 my
> build :
>=20
> [   84.629936] WARNING: kmemcheck: Caught 64-bit read from uninitiali=
zed memory (ffff88011a7376f0)
> [   84.629939] 5868ba1a0188ffff5868ba1a0188ffff7078731a0188ffffe0e118=
1a0188ffff
> [   84.629952]  i i i i i i i i i i i i i i i i u u u u u u u u u u u=
 u u u u u
> [   84.629963]                                  ^
> [   84.629964]=20
> [   84.629966] Pid: 2060, comm: 05-wait_for_sys Not tainted 2.6.39-rc=
4-00237-ge3de956-dirty #550 HP ProLiant BL460c G6
> [   84.629969] RIP: 0010:[<ffffffff810f0e80>]  [<ffffffff810f0e80>] k=
mem_cache_alloc+0x50/0x190
> [   84.629977] RSP: 0018:ffff88011a0b9988  EFLAGS: 00010286
> [   84.629979] RAX: 0000000000000000 RBX: ffff88011a739a98 RCX: 00000=
00000620780
> [   84.629980] RDX: 0000000000620740 RSI: 0000000000017400 RDI: fffff=
fff810db8f5
> [   84.629982] RBP: ffff88011a0b99b8 R08: ffff88011a261dd8 R09: 00000=
00000000009
> [   84.629983] R10: 0000000000000002 R11: ffff88011fffce00 R12: ffff8=
8011b00a600
> [   84.629985] R13: ffff88011a7376f0 R14: 00000000000000d0 R15: ffff8=
8011abbb0c0
> [   84.629987] FS:  0000000000000000(0000) GS:ffff88011fc00000(0063) =
knlGS:00000000f76ff6c0
> [   84.629989] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
> [   84.629991] CR2: ffff88011998dab8 CR3: 000000011a13f000 CR4: 00000=
000000006f0
> [   84.629992] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000=
00000000000
> [   84.629994] DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 00000=
00000000400
> [   84.629995]  [<ffffffff810db8f5>] anon_vma_prepare+0x55/0x190
> [   84.630000]  [<ffffffff810cfe90>] handle_pte_fault+0x470/0x6e0
> [   84.630002]  [<ffffffff810d1654>] handle_mm_fault+0x124/0x1a0
> [   84.630005]  [<ffffffff8147a510>] do_page_fault+0x160/0x560
> [   84.630008]  [<ffffffff81477fcf>] page_fault+0x1f/0x30
> [   84.630013]  [<ffffffff810b31f8>] generic_file_aio_read+0x528/0x74=
0
> [   84.630017]  [<ffffffff810f5461>] do_sync_read+0xd1/0x110
> [   84.630021]  [<ffffffff810f5c36>] vfs_read+0xc6/0x160
> [   84.630023]  [<ffffffff810f60b0>] sys_read+0x50/0x90
> [   84.630025]  [<ffffffff8147f4e9>] sysenter_dispatch+0x7/0x27
> [   84.630030]  [<ffffffffffffffff>] 0xffffffffffffffff
>=20
> ffffffff810f0e6d:       0f 84 b5 00 00 00       je     ffffffff810f0f=
28 <kmem_cache_alloc+0xf8>
> ffffffff810f0e73:       49 63 44 24 20          movslq 0x20(%r12),%ra=
x
> ffffffff810f0e78:       48 8d 4a 40             lea    0x40(%rdx),%rc=
x
> ffffffff810f0e7c:       49 8b 34 24             mov    (%r12),%rsi
> >>ffffffff810f0e80:       49 8b 5c 05 00          mov    0x0(%r13,%ra=
x,1),%rbx
> ffffffff810f0e85:       4c 89 e8                mov    %r13,%rax
> ffffffff810f0e88:       e8 83 19 0e 00          callq  ffffffff811d28=
10 <this_cpu_cmpxchg16b_emu>
> ffffffff810f0e8d:       0f 1f 40 00             nopl   0x0(%rax)
> ffffffff810f0e91:       84 c0                   test   %al,%al
> ffffffff810f0e93:       74 c1                   je     ffffffff810f0e=
56 <kmem_cache_alloc+0x26>
>=20
>=20
> So this is definitely the access to object->next that triggers the fa=
ult.
>=20
> Problem is : my (2nd) patch only reduces the window of occurrence of =
the bug, since we can
> be preempted/interrupted between the kmemcheck_mark_initialized() and=
 access to object->next :
>=20
> The preempt/irq could allocate the object and free it again.
>=20
> So KMEMCHECK would require us to block IRQ to be safe.
>=20
> Then, just disable SLUB_CMPXCHG_DOUBLE if KMEMCHECK is defined, as I =
did in my first patch.
>=20
> Christoph, please reconsider first version of patch (disabling SLUB_C=
MPXCHG_DOUBLE if
> either KMEMCHECK or DEBUG_PAGEALLOC is defined)

Or this alternate one : keep cmpxchg_double() stuff but block IRQ in
slab_alloc() if KMEMCHECK or DEBUG_PAGEALLOC

I tested it and got no kmemcheck splat

Thanks

[PATCH] slub: block IRQ in slab_alloc() if KMEMCHECK or DEBUG_PAGEALLOC

Christian Casteyde reported a KMEMCHECK splat in slub code.

Problem is now we are lockless and allow IRQ in slab_alloc, the object
we manipulate from freelist can be allocated and freed right before we
try to read object->next

Same problem can happen with DEBUG_PAGEALLOC

Reported-by: Christian Casteyde <casteyde.christian@free.fr>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Vegard Nossum <vegardno@ifi.uio.no>
Cc: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 94d2a33..9c34a2b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1881,7 +1881,13 @@ debug:
  * If not then __slab_alloc is called for slow processing.
  *
  * Otherwise we can simply pick the next object from the lockless free=
 list.
+ * Since we access object->next, we must disable irqs if KMEMCHECK or
+ * DEBUG_PAGEALLOC is defined, since object could be allocated and fre=
ed
+ * under us.
  */
+#if !defined(CONFIG_CMPXCHG_LOCAL) || defined(CONFIG_KMEMCHECK) || def=
ined(CONFIG_DEBUG_PAGEALLOC)
+#define MASK_IRQ_IN_SLAB_ALLOC
+#endif
 static __always_inline void *slab_alloc(struct kmem_cache *s,
 		gfp_t gfpflags, int node, unsigned long addr)
 {
@@ -1889,16 +1895,18 @@ static __always_inline void *slab_alloc(struct =
kmem_cache *s,
 	struct kmem_cache_cpu *c;
 #ifdef CONFIG_CMPXCHG_LOCAL
 	unsigned long tid;
-#else
+#endif
+#ifdef MASK_IRQ_IN_SLAB_ALLOC
 	unsigned long flags;
 #endif
=20
 	if (slab_pre_alloc_hook(s, gfpflags))
 		return NULL;
=20
-#ifndef CONFIG_CMPXCHG_LOCAL
+#ifdef MASK_IRQ_IN_SLAB_ALLOC
 	local_irq_save(flags);
-#else
+#endif
+#ifdef CONFIG_CMPXCHG_LOCAL
 redo:
 #endif
=20
@@ -1954,7 +1962,7 @@ redo:
 		stat(s, ALLOC_FASTPATH);
 	}
=20
-#ifndef CONFIG_CMPXCHG_LOCAL
+#ifdef MASK_IRQ_IN_SLAB_ALLOC
 	local_irq_restore(flags);
 #endif
=20



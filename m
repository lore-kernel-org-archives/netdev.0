From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 3/3] use SLAB_ALIGN_SMP
Date: Mon, 3 Mar 2008 10:36:24 +0100
Message-ID: <20080303093624.GC15091@wotan.suse.de>
References: <20080303093449.GA15091@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Christoph Lameter <clameter@engr.sg
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:50137 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752918AbYCCJgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 04:36:25 -0500
Content-Disposition: inline
In-Reply-To: <20080303093449.GA15091@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use SLAB_SMP_ALIGN in a few places.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/fs/block_dev.c
===================================================================
--- linux-2.6.orig/fs/block_dev.c
+++ linux-2.6/fs/block_dev.c
@@ -332,8 +332,8 @@ void __init bdev_cache_init(void)
 {
 	int err;
 	bdev_cachep = kmem_cache_create("bdev_cache", sizeof(struct bdev_inode),
-			0, (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT|
-				SLAB_MEM_SPREAD|SLAB_PANIC),
+			0, (SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|
+			SLAB_RECLAIM_ACCOUNT|SLAB_MEM_SPREAD|SLAB_PANIC),
 			init_once);
 	err = register_filesystem(&bd_type);
 	if (err)
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -1547,23 +1547,23 @@ void __init proc_caches_init(void)
 {
 	sighand_cachep = kmem_cache_create("sighand_cache",
 			sizeof(struct sighand_struct), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_DESTROY_BY_RCU,
+			SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|SLAB_PANIC|SLAB_DESTROY_BY_RCU,
 			sighand_ctor);
 	signal_cachep = kmem_cache_create("signal_cache",
 			sizeof(struct signal_struct), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+			SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|SLAB_PANIC, NULL);
 	files_cachep = kmem_cache_create("files_cache",
 			sizeof(struct files_struct), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+			SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|SLAB_PANIC, NULL);
 	fs_cachep = kmem_cache_create("fs_cache",
 			sizeof(struct fs_struct), 0,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+			SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|SLAB_PANIC, NULL);
 	vm_area_cachep = kmem_cache_create("vm_area_struct",
 			sizeof(struct vm_area_struct), 0,
 			SLAB_PANIC, NULL);
 	mm_cachep = kmem_cache_create("mm_struct",
 			sizeof(struct mm_struct), ARCH_MIN_MMSTRUCT_ALIGN,
-			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+			SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|SLAB_PANIC, NULL);
 }
 
 /*
Index: linux-2.6/kernel/pid.c
===================================================================
--- linux-2.6.orig/kernel/pid.c
+++ linux-2.6/kernel/pid.c
@@ -526,5 +526,5 @@ void __init pidmap_init(void)
 	atomic_dec(&init_pid_ns.pidmap[0].nr_free);
 
 	init_pid_ns.pid_cachep = KMEM_CACHE(pid,
-			SLAB_HWCACHE_ALIGN | SLAB_PANIC);
+			SLAB_HWCACHE_ALIGN | SLAB_SMP_ALIGN | SLAB_PANIC);
 }
Index: linux-2.6/kernel/user.c
===================================================================
--- linux-2.6.orig/kernel/user.c
+++ linux-2.6/kernel/user.c
@@ -503,7 +503,7 @@ static int __init uid_cache_init(void)
 	int n;
 
 	uid_cachep = kmem_cache_create("uid_cache", sizeof(struct user_struct),
-			0, SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
+			0, SLAB_HWCACHE_ALIGN|SLAB_SMP_ALIGN|SLAB_PANIC, NULL);
 
 	for(n = 0; n < UIDHASH_SZ; ++n)
 		INIT_HLIST_HEAD(init_user_ns.uidhash_table + n);

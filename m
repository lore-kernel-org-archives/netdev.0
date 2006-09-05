From: David Howells <dhowells@redhat.com>
Subject: [PATCH] NOMMU: Move the fallback arch_vma_name() to a sensible place
Date: Tue, 05 Sep 2006 16:27:04 +0100
Message-ID: <6024.1157470024@warthog.cambridge.redhat.com>
References: <20060905132530.GD9173@stusta.de>  <20060901015818.42767813.akpm@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965139AbWIEP3j@vger.kernel.org>
In-Reply-To: <20060905132530.GD9173@stusta.de> 
To: Adrian Bunk <bunk@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Move the fallback arch_vma_name() to a sensible place (kernel/signal.c).

Currently it's in fs/proc/task_mmu.c, a file that is dependent on both
CONFIG_PROC_FS and CONFIG_MMU being enabled, but it's used from kernel/signal.c
from where it is called unconditionally.

Signed-Off-By: David Howells <dhowells@redhat.com>
---
warthog>diffstat -p1 nommu-arch_vma_name-2618rc5mm1.diff 
 fs/proc/task_mmu.c |    5 -----
 kernel/signal.c    |    5 +++++
 2 files changed, 5 insertions(+), 5 deletions(-)

diff -urp ../kernels/linux-2.6.18-rc5-mm1/fs/proc/task_mmu.c linux-2.6.18-rc5-mm1-frv/fs/proc/task_mmu.c
--- ../kernels/linux-2.6.18-rc5-mm1/fs/proc/task_mmu.c	2006-09-04 18:02:43.000000000 +0100
+++ linux-2.6.18-rc5-mm1-frv/fs/proc/task_mmu.c	2006-09-05 15:49:18.000000000 +0100
@@ -122,11 +122,6 @@ struct mem_size_stats
 	unsigned long private_dirty;
 };
 
-__attribute__((weak)) const char *arch_vma_name(struct vm_area_struct *vma)
-{
-	return NULL;
-}
-
 static int show_map_internal(struct seq_file *m, void *v, struct mem_size_stats *mss)
 {
 	struct proc_maps_private *priv = m->private;
diff -urp ../kernels/linux-2.6.18-rc5-mm1/kernel/signal.c linux-2.6.18-rc5-mm1-frv/kernel/signal.c
--- ../kernels/linux-2.6.18-rc5-mm1/kernel/signal.c	2006-09-04 18:03:32.000000000 +0100
+++ linux-2.6.18-rc5-mm1-frv/kernel/signal.c	2006-09-05 15:49:19.000000000 +0100
@@ -773,6 +773,11 @@ static void pad_len_spaces(int len)
 	printk("%*c", len, ' ');
 }
 
+__attribute__((weak)) const char *arch_vma_name(struct vm_area_struct *vma)
+{
+	return NULL;
+}
+
 static int print_vma(struct vm_area_struct *vma)
 {
 	struct mm_struct *mm = vma->vm_mm;

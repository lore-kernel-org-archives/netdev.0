From: Richard Yao <ryao@gentoo.org>
Subject: [PATCH 1/2] mm/vmalloc: export is_vmalloc_or_module_addr
Date: Sat,  8 Feb 2014 14:12:09 -0500
Message-ID: <1391886730-19667-2-git-send-email-ryao@gentoo.org>
References: <1391886730-19667-1-git-send-email-ryao@gentoo.org>
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S. Miller" <davem@davemloft.net>,
	V9FS Develooper Mailing List
	<v9fs-developer@lists.sourceforge.net>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	Will Deacon <will.deacon@arm.com>,
	Christopher Covington <cov@codeaurora.org>,
	Matthew Thode <mthode@mthode.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391886730-19667-1-git-send-email-ryao@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

9p-virtio needs is_vmalloc_or_module_addr exported before a patch can be
merged to prevent the virtio zero-copy routines from triggering a
hypervisor page fault when loading kernel modules:

https://groups.google.com/forum/#!topic/linux.kernel/eRR7AyLE29Y

Without this export, the kernel build breaks with that patch applied and
CONFIG_NET_9P_VIRTIO=m. With this export in place, all is well.

Signed-off-by: Richard Yao <ryao@gentoo.org>
---
 mm/vmalloc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0fdf968..8a2e54f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -218,6 +218,7 @@ int is_vmalloc_or_module_addr(const void *x)
 #endif
 	return is_vmalloc_addr(x);
 }
+EXPORT_SYMBOL(is_vmalloc_or_module_addr);
 
 /*
  * Walk a vmap address to the struct page it maps.
-- 
1.8.3.2

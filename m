From: Andrew Morton <akpm@osdl.org>
Subject: add-a-slab-for-ethernet.patch
Date: Mon, 12 Apr 2004 22:25:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040412222532.25c7e1b9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I've been sitting on this for a while:


From: Manfred Spraul <manfred@colorfullife.com>

Improve the packing density for 1536-byte ethernet frames on 8k or larger
page size machines.

The slab has 1620 bytes - 5 should fit into one page (1620*5+40 bytes
slab+5*4 bufctl - 32 bytes should remain unused on 64-bit archs).



---

 25-akpm/include/linux/kmalloc_sizes.h |    3 +++
 1 files changed, 3 insertions(+)

diff -puN include/linux/kmalloc_sizes.h~add-a-slab-for-ethernet include/linux/kmalloc_sizes.h
--- 25/include/linux/kmalloc_sizes.h~add-a-slab-for-ethernet	Tue Feb 24 14:40:06 2004
+++ 25-akpm/include/linux/kmalloc_sizes.h	Tue Feb 24 14:40:06 2004
@@ -12,6 +12,9 @@
 	CACHE(256)
 	CACHE(512)
 	CACHE(1024)
+#if (PAGE_SIZE != 4096)	/* special cache for eth skbs - 5 fit into one 8 kB page */
+	CACHE(1620)
+#endif
 	CACHE(2048)
 	CACHE(4096)
 	CACHE(8192)

_


Problem is, I'm not sure it's worth the effort - it seems that the system
just never has that many full-sized ethernet frames floating about, so we
don't save significant amounts of memory.


Am I wrong?

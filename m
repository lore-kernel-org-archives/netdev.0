From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH,RFC] [NET] ALIGN
Date: Mon, 09 Feb 2004 13:45:28 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209.134528.28683257.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

D: Use ALIGN() where appricable.

BTW, 
 1. do we really need this ALIGN?
 2. should 16 be BYTES_PER_WORD (in mm/slab.c)?

===== net/core/neighbour.c 1.24 vs edited =====
--- 1.24/net/core/neighbour.c	Tue Jan 20 14:31:23 2004
+++ edited/net/core/neighbour.c	Mon Feb  9 13:13:37 2004
@@ -1164,8 +1164,7 @@
 
 	if (!tbl->kmem_cachep)
 		tbl->kmem_cachep = kmem_cache_create(tbl->id,
-						     (tbl->entry_size +
-						      15) & ~15,
+						     ALIGN(tbl->entry_size, 16),
 						     0, SLAB_HWCACHE_ALIGN,
 						     NULL, NULL);
 	tbl->lock	       = RW_LOCK_UNLOCKED;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

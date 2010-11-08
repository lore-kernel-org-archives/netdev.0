From: Paul Mundt <lethal@linux-sh.org>
Subject: [PATCH] net dst: need linux/cache.h for ____cacheline_aligned_in_smp.
Date: Mon, 8 Nov 2010 12:51:30 +0900
Message-ID: <20101108035130.GA11477@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 124x34x33x190.ap124.ftth.ucom.ne.jp ([124.34.33.190]:58091 "EHLO
	master.linux-sh.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252Ab0KHDvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 22:51:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Presently the b43legacy build fails on an sh randconfig:

In file included from include/net/dst.h:12,
                 from drivers/net/wireless/b43legacy/xmit.c:32:
include/net/dst_ops.h:28: error: expected ':', ',', ';', '}' or '__attribute__' before '____cacheline_aligned_in_smp'
include/net/dst_ops.h: In function 'dst_entries_get_fast':
include/net/dst_ops.h:33: error: 'struct dst_ops' has no member named 'pcpuc_entries'
include/net/dst_ops.h: In function 'dst_entries_get_slow':
include/net/dst_ops.h:41: error: 'struct dst_ops' has no member named 'pcpuc_entries'
include/net/dst_ops.h: In function 'dst_entries_add':
include/net/dst_ops.h:49: error: 'struct dst_ops' has no member named 'pcpuc_entries'
include/net/dst_ops.h: In function 'dst_entries_init':
include/net/dst_ops.h:55: error: 'struct dst_ops' has no member named 'pcpuc_entries'
include/net/dst_ops.h: In function 'dst_entries_destroy':
include/net/dst_ops.h:60: error: 'struct dst_ops' has no member named 'pcpuc_entries'
make[5]: *** [drivers/net/wireless/b43legacy/xmit.o] Error 1
make[5]: *** Waiting for unfinished jobs....

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

---

 include/net/dst_ops.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/dst_ops.h b/include/net/dst_ops.h
index 1fa5306..51665b3 100644
--- a/include/net/dst_ops.h
+++ b/include/net/dst_ops.h
@@ -2,6 +2,7 @@
 #define _NET_DST_OPS_H
 #include <linux/types.h>
 #include <linux/percpu_counter.h>
+#include <linux/cache.h>
 
 struct dst_entry;
 struct kmem_cachep;

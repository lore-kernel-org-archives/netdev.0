From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH] fix uninitialized proto_list_lock
Date: Mon, 4 Apr 2005 13:30:10 -0400
Message-ID: <20050404173010.GA19451@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply the following patch which fixes a BUG() on boot when the 
kernel is compiled with spinlock debugging in bk head.  Cheers,

		-ben

===== net/core/sock.c 1.67 vs edited =====
--- 1.67/net/core/sock.c	2005-03-26 18:04:35 -05:00
+++ edited/net/core/sock.c	2005-04-04 12:46:26 -04:00
@@ -1352,7 +1352,7 @@
 
 EXPORT_SYMBOL(sk_common_release);
 
-static rwlock_t proto_list_lock;
+static rwlock_t proto_list_lock = RW_LOCK_UNLOCKED;
 static LIST_HEAD(proto_list);
 
 int proto_register(struct proto *prot, int alloc_slab)

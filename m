From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Fix locking bug in lltx path
Date: Mon, 13 Sep 2004 20:11:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3vfei9gzv.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, arjanv@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Thanks to Arjan's spinlock debug kernel for finding it.

This fixes a silly missing spin lock in the relock path. For some 
reason it seems to still work when you don't have spinlock debugging
enabled.

Please apply.

-Andi

--------------------------------------------------------------------

Fix missing spin lock in lltx path.

Thanks to Arjan's spinlock debug kernel for finding it.

Signed-off-by: Andi Kleen <ak@muc.de>

diff -u linux-2.6.9rc1-bk19/net/sched/sch_generic.c-X linux-2.6.9rc1-bk19/net/sched/sch_generic.c
--- linux-2.6.9rc1-bk19/net/sched/sch_generic.c-X	2004-09-13 08:51:46.000000000 +0200
+++ linux-2.6.9rc1-bk19/net/sched/sch_generic.c	2004-09-13 19:22:50.000000000 +0200
@@ -153,8 +153,10 @@
 					spin_lock(&dev->queue_lock);
 					return -1;
 				}
-				if (ret == -1 && nolock)
+				if (ret == -1 && nolock) {
+					spin_lock(&dev->queue_lock);
 					goto collision; 
+				}
 			}
 
 			/* Release the driver */

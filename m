From: domen@coderock.org
Subject: [patch 2/5] net/aarp: replace schedule_timeout() with msleep()
Date: Sun, 06 Mar 2005 23:21:11 +0100
Message-ID: <20050306222111.C65C11ED3D@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com
To: davem@redhat.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Use msleep() instead of schedule_timeout() to guarantee the task
delays as expected. The current code is not wrong, but it does not account for
early return due to signals, so I think msleep() should be appropriate.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/net/appletalk/aarp.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff -puN net/appletalk/aarp.c~msleep-net_appletalk_aarp net/appletalk/aarp.c
--- kj/net/appletalk/aarp.c~msleep-net_appletalk_aarp	2005-03-05 16:10:58.000000000 +0100
+++ kj-domen/net/appletalk/aarp.c	2005-03-05 16:10:58.000000000 +0100
@@ -35,6 +35,7 @@
 #include <net/datalink.h>
 #include <net/psnap.h>
 #include <linux/atalk.h>
+#include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
@@ -462,8 +463,7 @@ void aarp_probe_network(struct atalk_ifa
 			aarp_send_probe(atif->dev, &atif->address);
 
 			/* Defer 1/10th */
-			current->state = TASK_INTERRUPTIBLE;
-			schedule_timeout(HZ / 10);
+			msleep(100);
 
 			if (atif->status & ATIF_PROBE_FAIL)
 				break;
@@ -510,9 +510,8 @@ int aarp_proxy_probe_network(struct atal
 		aarp_send_probe(atif->dev, sa);
 
 		/* Defer 1/10th */
-		current->state = TASK_INTERRUPTIBLE;
 		write_unlock_bh(&aarp_lock);
-		schedule_timeout(HZ / 10);
+		msleep(100);
 		write_lock_bh(&aarp_lock);
 
 		if (entry->status & ATIF_PROBE_FAIL)
_

From: Felipe W Damasio <felipewd@terra.com.br>
Subject: [PATCH] Unneeded memory barrier in net/irda code
Date: Tue, 16 Sep 2003 16:53:42 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F676A46.2000304@terra.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080006050605090009040301"
Cc: irda-users@lists.sourceforge.net, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080006050605090009040301
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

	Hi Jeff,

	Patch against 2.6-test5 to remove 2 unneeded memory barriers when 
setting current to TASK_RUNNING.

	Please consider applying.

	Thanks,

Felipe

--------------080006050605090009040301
Content-Type: text/plain;
 name="irda-mb.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="irda-mb.patch"

--- linux-2.6.0-test5/drivers/net/irda/sir_kthread.c.orig	2003-09-16 16:49:52.000000000 -0300
+++ linux-2.6.0-test5/drivers/net/irda/sir_kthread.c	2003-09-16 16:50:09.000000000 -0300
@@ -132,7 +132,7 @@
 		if (list_empty(&irda_rq_queue.request_list))
 			schedule();
 		else
-			set_task_state(current, TASK_RUNNING);
+			__set_task_state(current, TASK_RUNNING);
 		remove_wait_queue(&irda_rq_queue.kick, &wait);
 
 		/* make swsusp happy with our thread */
@@ -165,7 +165,7 @@
 		if (atomic_read(&irda_rq_queue.num_pending))
 			schedule();
 		else
-			set_task_state(current, TASK_RUNNING);
+			__set_task_state(current, TASK_RUNNING);
 		remove_wait_queue(&irda_rq_queue.done, &wait);
 	}
 }

--------------080006050605090009040301--

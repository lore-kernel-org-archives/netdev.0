From: Felipe W Damasio <felipewd@terra.com.br>
Subject: [PATCH] unneeded memory barrier in olympic tokenring driver
Date: Sun, 28 Sep 2003 18:57:08 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F775934.5080004@terra.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000309040203080606010809"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com, linux-tr@linuxtr.net
Return-path: <netdev-bounce@oss.sgi.com>
To: mikep@linuxtr.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000309040203080606010809
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

	Hi Daniel,

	Patch against 2.6.0-test6.

	Removes 2 unneeded memory barriers when setting the current task to 
TASK_RUNNING.

	Please consider applying,

Felipe
-- 
It's most certainly GNU/Linux, not Linux. Read more at
http://www.gnu.org/gnu/why-gnu-linux.html

--------------000309040203080606010809
Content-Type: text/plain;
 name="olympic-barrier.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="olympic-barrier.patch"

--- linux-2.6.0-test6/drivers/net/tokenring/olympic.c.orig	Sun Sep 28 18:51:13 2003
+++ linux-2.6.0-test6/drivers/net/tokenring/olympic.c	Sun Sep 28 18:51:36 2003
@@ -531,7 +531,7 @@
 			set_current_state(TASK_INTERRUPTIBLE) ; 
     		}
 		remove_wait_queue(&olympic_priv->srb_wait,&wait) ; 
-		set_current_state(TASK_RUNNING) ; 
+		__set_current_state(TASK_RUNNING) ; 
 		olympic_priv->srb_queued = 0 ; 
 #if OLYMPIC_DEBUG
 		printk("init_srb(%p): ",init_srb);
@@ -1122,7 +1122,7 @@
 		set_current_state(TASK_INTERRUPTIBLE) ; 
     	}
 	remove_wait_queue(&olympic_priv->srb_wait,&wait) ; 
-	set_current_state(TASK_RUNNING) ; 
+	__set_current_state(TASK_RUNNING) ; 
 
 	olympic_priv->rx_status_last_received++;
 	olympic_priv->rx_status_last_received&=OLYMPIC_RX_RING_SIZE-1;

--------------000309040203080606010809--

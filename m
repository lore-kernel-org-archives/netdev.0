From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/11) ep7211_ir dongle -- module owner
Date: Thu, 2 Oct 2003 15:28:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002152812.2bddb04d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller"
 <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert ep7211_ir dongle to use module owner.

diff -Nru a/drivers/net/irda/ep7211_ir.c b/drivers/net/irda/ep7211_ir.c
--- a/drivers/net/irda/ep7211_ir.c	Thu Oct  2 15:10:34 2003
+++ b/drivers/net/irda/ep7211_ir.c	Thu Oct  2 15:10:34 2003
@@ -24,12 +24,12 @@
 static int  ep7211_ir_reset(struct irda_task *task);
 
 static struct dongle_reg dongle = {
-	Q_NULL,
-	IRDA_EP7211_IR,
-	ep7211_ir_open,
-	ep7211_ir_close,
-	ep7211_ir_reset,
-	ep7211_ir_change_speed,
+	.type = IRDA_EP7211_IR,
+	.open = ep7211_ir_open,
+	.close = ep7211_ir_close,
+	.reset = ep7211_ir_reset,
+	.change_speed = ep7211_ir_change_speed,
+	.owner = THIS_MODULE,
 };
 
 static void ep7211_ir_open(dongle_t *self, struct qos_info *qos)
@@ -47,8 +47,6 @@
 		UART (interrupt #14). */
 
 	restore_flags(flags);
-
-	MOD_INC_USE_COUNT;
 }
 
 static void ep7211_ir_close(dongle_t *self)
@@ -66,8 +64,6 @@
 		reset them back to their original state. */
 
 	restore_flags(flags);
-
-	MOD_DEC_USE_COUNT;
 }
 
 /*

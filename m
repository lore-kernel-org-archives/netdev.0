From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (8/11) litelink dongle -- module owner
Date: Thu, 2 Oct 2003 15:27:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002152701.118303b1.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert litelink dongle to use module owner

diff -Nru a/drivers/net/irda/litelink.c b/drivers/net/irda/litelink.c
--- a/drivers/net/irda/litelink.c	Thu Oct  2 15:10:41 2003
+++ b/drivers/net/irda/litelink.c	Thu Oct  2 15:10:41 2003
@@ -48,12 +48,12 @@
 static __u32 baud_rates[] = { 115200, 57600, 38400, 19200, 9600 };
 
 static struct dongle_reg dongle = {
-	Q_NULL,
-	IRDA_LITELINK_DONGLE,
-	litelink_open,
-	litelink_close,
-	litelink_reset,
-	litelink_change_speed,
+	.type = IRDA_LITELINK_DONGLE,
+	.open = litelink_open,
+	.close = litelink_close,
+	.reset = litelink_reset,
+	.change_speed = litelink_change_speed,
+	.owner = THIS_MODULE,
 };
 
 int __init litelink_init(void)
@@ -70,16 +70,12 @@
 {
 	qos->baud_rate.bits &= IR_9600|IR_19200|IR_38400|IR_57600|IR_115200;
 	qos->min_turn_time.bits = 0x7f; /* Needs 0.01 ms */
-
-	MOD_INC_USE_COUNT;
 }
 
 static void litelink_close(dongle_t *self)
 {
 	/* Power off dongle */
 	self->set_dtr_rts(self->dev, FALSE, FALSE);
-
-	MOD_DEC_USE_COUNT;
 }
 
 /*

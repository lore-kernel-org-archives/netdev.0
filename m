From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH} (4/11) actisys donge --  module owner
Date: Thu, 2 Oct 2003 15:28:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002152800.6bbbc0f6.shemminger@osdl.org>
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

Convert actisys to use owner field.

diff -Nru a/drivers/net/irda/actisys.c b/drivers/net/irda/actisys.c
--- a/drivers/net/irda/actisys.c	Thu Oct  2 15:10:31 2003
+++ b/drivers/net/irda/actisys.c	Thu Oct  2 15:10:31 2003
@@ -64,21 +64,21 @@
 #define MAX_SPEEDS 5
 
 static struct dongle_reg dongle = {
-	Q_NULL,
-	IRDA_ACTISYS_DONGLE,
-	actisys_open,
-	actisys_close,
-	actisys_reset,
-	actisys_change_speed,
+	.type = IRDA_ACTISYS_DONGLE,
+	.open = actisys_open,
+	.close = actisys_close,
+	.reset = actisys_reset,
+	.change_speed = actisys_change_speed,
+	.owner = THIS_MODULE,
 };
 
 static struct dongle_reg dongle_plus = {
-	Q_NULL,
-	IRDA_ACTISYS_PLUS_DONGLE,
-	actisys_open,
-	actisys_close,
-	actisys_reset,
-	actisys_change_speed,
+	.type = IRDA_ACTISYS_PLUS_DONGLE,
+	.open = actisys_open,
+	.close = actisys_close,
+	.reset = actisys_reset,
+	.change_speed = actisys_change_speed,
+	.owner = THIS_MODULE,
 };
 
 /*
@@ -128,16 +128,12 @@
 		qos->baud_rate.bits &= ~IR_38400;
 	
 	qos->min_turn_time.bits = 0x7f; /* Needs 0.01 ms */
-
-	MOD_INC_USE_COUNT;
 }
 
 static void actisys_close(dongle_t *self)
 {
 	/* Power off the dongle */
 	self->set_dtr_rts(self->dev, FALSE, FALSE);
-
-	MOD_DEC_USE_COUNT;
 }
 
 /*

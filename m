From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/11) girbil dongle -- module owner
Date: Thu, 2 Oct 2003 15:31:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002153148.18da36da.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert girbil dongle to use module owner instead of MOD_INC/DEC

diff -Nru a/drivers/net/irda/girbil.c b/drivers/net/irda/girbil.c
--- a/drivers/net/irda/girbil.c	Thu Oct  2 15:10:39 2003
+++ b/drivers/net/irda/girbil.c	Thu Oct  2 15:10:39 2003
@@ -63,12 +63,12 @@
 #define GIRBIL_LOAD    0x51 /* Load the new baud rate value */
 
 static struct dongle_reg dongle = {
-	Q_NULL,
-	IRDA_GIRBIL_DONGLE,
-	girbil_open,
-	girbil_close,
-	girbil_reset,
-	girbil_change_speed,
+	.type = IRDA_GIRBIL_DONGLE,
+	.open = girbil_open,
+	.close = girbil_close,
+	.reset = girbil_reset,
+	.change_speed = girbil_change_speed,
+	.owner = THIS_MODULE,
 };
 
 int __init girbil_init(void)
@@ -85,16 +85,12 @@
 {
 	qos->baud_rate.bits &= IR_9600|IR_19200|IR_38400|IR_57600|IR_115200;
 	qos->min_turn_time.bits = 0x03;
-
-	MOD_INC_USE_COUNT;
 }
 
 static void girbil_close(dongle_t *self)
 {
 	/* Power off dongle */
 	self->set_dtr_rts(self->dev, FALSE, FALSE);
-
-	MOD_DEC_USE_COUNT;
 }
 
 /*

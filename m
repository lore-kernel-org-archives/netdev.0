From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/11) tekram dongle module conversion
Date: Thu, 2 Oct 2003 15:20:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002152031.779022e5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nru a/drivers/net/irda/tekram.c b/drivers/net/irda/tekram.c
--- a/drivers/net/irda/tekram.c	Thu Oct  2 15:10:26 2003
+++ b/drivers/net/irda/tekram.c	Thu Oct  2 15:10:26 2003
@@ -44,12 +44,12 @@
 #define TEKRAM_PW     0x10 /* Pulse select bit */
 
 static struct dongle_reg dongle = {
-	Q_NULL,
-	IRDA_TEKRAM_DONGLE,
-	tekram_open,
-	tekram_close,
-	tekram_reset,
-	tekram_change_speed,
+	.type = IRDA_TEKRAM_DONGLE,
+	.open  = tekram_open,
+	.close = tekram_close,
+	.reset = tekram_reset,
+	.change_speed = tekram_change_speed,
+	.owner = THIS_MODULE,
 };
 
 int __init tekram_init(void)
@@ -69,8 +69,6 @@
 	qos->baud_rate.bits &= IR_9600|IR_19200|IR_38400|IR_57600|IR_115200;
 	qos->min_turn_time.bits = 0x01; /* Needs at least 10 ms */	
 	irda_qos_bits_to_value(qos);
-
-	MOD_INC_USE_COUNT;
 }
 
 static void tekram_close(dongle_t *self)
@@ -84,8 +82,6 @@
 		irda_task_delete(self->reset_task);
 	if (self->speed_task)
 		irda_task_delete(self->speed_task);
-
-	MOD_DEC_USE_COUNT;
 }
 
 /*

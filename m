From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/11) act200l dongle --  module owner
Date: Thu, 2 Oct 2003 15:27:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002152741.656610bd.shemminger@osdl.org>
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

Convert act200l dongle to use module owner.

diff -Nru a/drivers/net/irda/act200l.c b/drivers/net/irda/act200l.c
--- a/drivers/net/irda/act200l.c	Thu Oct  2 15:10:29 2003
+++ b/drivers/net/irda/act200l.c	Thu Oct  2 15:10:29 2003
@@ -84,12 +84,12 @@
 #define ACT200L_OSCL    0x04 /* oscillator in low power, medium accuracy mode */
 
 static struct dongle_reg dongle = {
-	Q_NULL,
-	IRDA_ACT200L_DONGLE,
-	act200l_open,
-	act200l_close,
-	act200l_reset,
-	act200l_change_speed,
+	.type = IRDA_ACT200L_DONGLE,
+	.open = act200l_open,
+	.close = act200l_close,
+	.reset = act200l_reset,
+	.change_speed = act200l_change_speed,
+	.owner = THIS_MODULE,
 };
 
 int __init act200l_init(void)
@@ -112,8 +112,6 @@
 	/* Set the speeds we can accept */
 	qos->baud_rate.bits &= IR_9600|IR_19200|IR_38400|IR_57600|IR_115200;
 	qos->min_turn_time.bits = 0x03;
-
-	MOD_INC_USE_COUNT;
 }
 
 static void act200l_close(dongle_t *self)
@@ -122,8 +120,6 @@
 
 	/* Power off the dongle */
 	self->set_dtr_rts(self->dev, FALSE, FALSE);
-
-	MOD_DEC_USE_COUNT;
 }
 
 /*

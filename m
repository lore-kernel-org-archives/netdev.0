From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (11/11) old_belkin dongle module conversion
Date: Thu, 2 Oct 2003 15:35:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002153515.7897b1ca.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change old_belkin dongle to new module owner support.

diff -Nru a/drivers/net/irda/old_belkin.c b/drivers/net/irda/old_belkin.c
--- a/drivers/net/irda/old_belkin.c	Thu Oct  2 15:10:48 2003
+++ b/drivers/net/irda/old_belkin.c	Thu Oct  2 15:10:48 2003
@@ -74,12 +74,12 @@
 /* static __u32 baud_rates[] = { 9600 }; */
 
 static struct dongle_reg dongle = {
-	Q_NULL,
-	IRDA_OLD_BELKIN_DONGLE,
-	old_belkin_open,
-	old_belkin_close,
-	old_belkin_reset,
-	old_belkin_change_speed,
+	.type = IRDA_OLD_BELKIN_DONGLE,
+	.open = old_belkin_open,
+	.close = old_belkin_close,
+	.reset = old_belkin_reset,
+	.change_speed = old_belkin_change_speed,
+	.owner = THIS_MODULE,
 };
 
 int __init old_belkin_init(void)
@@ -98,16 +98,12 @@
 	qos->baud_rate.bits &= IR_9600;
 	/* Needs at least 10 ms (totally wild guess, can do probably better) */
 	qos->min_turn_time.bits = 0x01;
-
-	MOD_INC_USE_COUNT;
 }
 
 static void old_belkin_close(dongle_t *self)
 {
 	/* Power off dongle */
 	self->set_dtr_rts(self->dev, FALSE, FALSE);
-
-	MOD_DEC_USE_COUNT;
 }
 
 /*

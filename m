From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/11) esi dongle - module owner
Date: Thu, 2 Oct 2003 15:25:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002152557.59dec7ce.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert ESI dongle to use module owner

diff -Nru a/drivers/net/irda/esi.c b/drivers/net/irda/esi.c
--- a/drivers/net/irda/esi.c	Thu Oct  2 15:10:36 2003
+++ b/drivers/net/irda/esi.c	Thu Oct  2 15:10:36 2003
@@ -44,12 +44,12 @@
 static int  esi_reset(struct irda_task *task);
 
 static struct dongle_reg dongle = {
-	Q_NULL,
-	IRDA_ESI_DONGLE,
-	esi_open,
-	esi_close,
-	esi_reset,
-	esi_change_speed,
+	.type = IRDA_ESI_DONGLE,
+	.open = esi_open,
+	.close = esi_close,
+	.reset = esi_reset,
+	.change_speed = esi_change_speed,
+	.owner = THIS_MODULE,
 };
 
 int __init esi_init(void)
@@ -66,16 +66,12 @@
 {
 	qos->baud_rate.bits &= IR_9600|IR_19200|IR_115200;
 	qos->min_turn_time.bits = 0x01; /* Needs at least 10 ms */
-
-	MOD_INC_USE_COUNT;
 }
 
 static void esi_close(dongle_t *dongle)
 {		
 	/* Power off dongle */
 	dongle->set_dtr_rts(dongle->dev, FALSE, FALSE);
-
-	MOD_DEC_USE_COUNT;
 }
 
 /*

From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (9/11) ma600 dongle -- module owner
Date: Thu, 2 Oct 2003 15:35:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002153510.6bdd33bc.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yet another conversion of dongle from MOD_INC/DEC to module owner field.

diff -Nru a/drivers/net/irda/ma600.c b/drivers/net/irda/ma600.c
--- a/drivers/net/irda/ma600.c	Thu Oct  2 15:10:43 2003
+++ b/drivers/net/irda/ma600.c	Thu Oct  2 15:10:43 2003
@@ -74,12 +74,12 @@
 #define MA600_2400	0x08
 
 static struct dongle_reg dongle = {
-	Q_NULL,
-	IRDA_MA600_DONGLE,
-	ma600_open,
-	ma600_close,
-	ma600_reset,
-	ma600_change_speed,
+	.type = IRDA_MA600_DONGLE,
+	.open = ma600_open,
+	.close = ma600_close,
+	.reset = ma600_reset,
+	.change_speed = ma600_change_speed,
+	.owner = THIS_MODULE,
 };
 
 int __init ma600_init(void)
@@ -115,8 +115,6 @@
 
 	self->set_dtr_rts(self->dev, TRUE, TRUE);
 	// should wait 1 second
-
-	MOD_INC_USE_COUNT;
 }
 
 static void ma600_close(dongle_t *self)
@@ -125,8 +123,6 @@
 
 	/* Power off dongle */
 	self->set_dtr_rts(self->dev, FALSE, FALSE);
-
-	MOD_DEC_USE_COUNT;
 }
 
 static __u8 get_control_byte(__u32 speed)

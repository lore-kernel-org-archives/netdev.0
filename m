From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (10/11) mcp2120 dongle -- module owner
Date: Thu, 2 Oct 2003 15:35:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002153514.14e5d917.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>, irda-users@lists.sourceforge.net,
        netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert mcp2120 dongle to use module owner instead of MOD_INC/DEC

diff -Nru a/drivers/net/irda/mcp2120.c b/drivers/net/irda/mcp2120.c
--- a/drivers/net/irda/mcp2120.c	Thu Oct  2 15:10:46 2003
+++ b/drivers/net/irda/mcp2120.c	Thu Oct  2 15:10:46 2003
@@ -40,12 +40,12 @@
 #define MCP2120_COMMIT  0x11
 
 static struct dongle_reg dongle = {
-	Q_NULL,
-	IRDA_MCP2120_DONGLE,
-	mcp2120_open,
-	mcp2120_close,
-	mcp2120_reset,
-	mcp2120_change_speed,
+	.type = IRDA_MCP2120_DONGLE,
+	.open = mcp2120_open,
+	.close = mcp2120_close,
+	.reset = mcp2120_reset,
+	.change_speed = mcp2120_change_speed,
+	.owner = THIS_MODULE,
 };
 
 int __init mcp2120_init(void)
@@ -62,8 +62,6 @@
 {
 	qos->baud_rate.bits &= IR_9600|IR_19200|IR_38400|IR_57600|IR_115200;
 	qos->min_turn_time.bits = 0x01;
-
-	MOD_INC_USE_COUNT;
 }
 
 static void mcp2120_close(dongle_t *self)
@@ -72,8 +70,6 @@
         /* reset and inhibit mcp2120 */
 	self->set_dtr_rts(self->dev, TRUE, TRUE);
 	//self->set_dtr_rts(self->dev, FALSE, FALSE);
-
-	MOD_DEC_USE_COUNT;
 }
 
 /*

From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] can: c_can: precedence error in c_can_chip_config()
Date: Sat, 9 Jun 2012 18:56:45 +0300
Message-ID: <20120609155150.GA6488@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	AnilKumar Ch <anilkumar@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <jkosina@suse.cz>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(CAN_CTRLMODE_LISTENONLY & CAN_CTRLMODE_LOOPBACK) is (0x02 & 0x01) which
is zero so the condition is never true.  The intent here was to test
that both flags were set.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This is a static checker fix.  I'm not super familiar with the c_can
code.

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index e2ce508..eea6608 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -594,8 +594,8 @@ static void c_can_chip_config(struct net_device *dev)
 	priv->write_reg(priv, C_CAN_CTRL_REG,
 			CONTROL_ENABLE_AR);
 
-	if (priv->can.ctrlmode & (CAN_CTRLMODE_LISTENONLY &
-					CAN_CTRLMODE_LOOPBACK)) {
+	if ((priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) &&
+	    (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)) {
 		/* loopback + silent mode : useful for hot self-test */
 		priv->write_reg(priv, C_CAN_CTRL_REG, CONTROL_EIE |
 				CONTROL_SIE | CONTROL_IE | CONTROL_TEST);

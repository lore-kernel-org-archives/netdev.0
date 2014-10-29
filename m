From: Dong Aisheng <b29396@freescale.com>
Subject: [PATCH 5/7] can: clear ctrlmode when close candev
Date: Wed, 29 Oct 2014 18:45:25 +0800
Message-ID: <1414579527-31100-5-git-send-email-b29396@freescale.com>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, varkabhadram@gmail.com, mkl@pengutronix.de,
 linux-arm-kernel@lists.infradead.org, socketcan@hartkopp.net,
 b29396@freescale.com, wg@grandegger.com
To: <linux-can@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1414579527-31100-1-git-send-email-b29396@freescale.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Currently priv->ctrlmode is not cleared when close_candev, so next time
the driver will still use this value to set controller even user
does not set any ctrl mode.
e.g.
Step 1. ip link set can0 up type can0 bitrate 1000000 loopback on
Controller will be in loopback mode
Step 2. ip link set can0 down
Step 3. ip link set can0 up type can0 bitrate 1000000
Controller will still be set to loopback mode in driver due to saved
priv->ctrlmode.

This patch clears priv->ctrlmode when the CAN interface is closed,
and set it to correct mode according to next user setting.

Signed-off-by: Dong Aisheng <b29396@freescale.com>
---
 drivers/net/can/dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 02492d2..1fce485 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -671,6 +671,7 @@ void close_candev(struct net_device *dev)
 
 	del_timer_sync(&priv->restart_timer);
 	can_flush_echo_skb(dev);
+	priv->ctrlmode = 0;
 }
 EXPORT_SYMBOL_GPL(close_candev);
 
-- 
1.9.1

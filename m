From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Subject: [PATCH 1/2] can: xilinx: use readl/writel instead of ioread/iowrite
Date: Thu, 22 Oct 2015 10:16:02 +0530
Message-ID: <1445489163-11045-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-can@vger.kernel.org
To: <anirudh@xilinx.com>, <wg@grandegger.com>, <mkl@pengutronix.de>,
 <michal.simek@xilinx.com>, <soren.brinkmann@xilinx.com>, <appanad@xilinx.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

The driver only supports memory-mapped I/O [by ioremap()],
so readl/writel is actually the right thing to do, IMO.
During the validation of this driver or IP on ARM 64-bit processor
while sending lot of packets observed that the tx packet drop with iowrite
Putting the barriers for each tx fifo register write fixes this issue
Instead of barriers using writel also fixed this issue.

Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
---
 drivers/net/can/xilinx_can.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_can.c
index 6114214..055d6f3 100644
--- a/drivers/net/can/xilinx_can.c
+++ b/drivers/net/can/xilinx_can.c
@@ -170,7 +170,7 @@ static const struct can_bittiming_const xcan_bittiming_const = {
 static void xcan_write_reg_le(const struct xcan_priv *priv, enum xcan_reg reg,
 			u32 val)
 {
-	iowrite32(val, priv->reg_base + reg);
+	writel(val, priv->reg_base + reg);
 }
 
 /**
@@ -183,7 +183,7 @@ static void xcan_write_reg_le(const struct xcan_priv *priv, enum xcan_reg reg,
  */
 static u32 xcan_read_reg_le(const struct xcan_priv *priv, enum xcan_reg reg)
 {
-	return ioread32(priv->reg_base + reg);
+	return readl(priv->reg_base + reg);
 }
 
 /**
-- 
2.1.2

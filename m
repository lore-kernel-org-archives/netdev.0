From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH] cs89x0 : packet reception not working
Date: Sun, 26 Aug 2012 23:39:06 +0200
Message-ID: <1346017146-28248-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.hauer@pengutronix.de, festevam@gmail.com,
 Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>,
 linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net,
	joe@perches.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The RxCFG register of the CS89x0 could be configured incorrectly
(because of misplaced parentheses), resulting in the disabling
of packet reception.

Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
---
 drivers/net/ethernet/cirrus/cs89x0.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 845b202..ea521fa 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -1261,10 +1261,10 @@ static void set_multicast_list(struct net_device *dev)
 	 * so we have to enable interrupts on them also
 	 */
 	writereg(dev, PP_RxCFG,
-		 (lp->curr_rx_cfg |
-		  (lp->rx_mode == RX_ALL_ACCEPT)
-		  ? (RX_CRC_ERROR_ENBL | RX_RUNT_ENBL | RX_EXTRA_DATA_ENBL)
-		  : 0));
+		 lp->curr_rx_cfg |
+		 (lp->rx_mode == RX_ALL_ACCEPT
+		 ? (RX_CRC_ERROR_ENBL | RX_RUNT_ENBL | RX_EXTRA_DATA_ENBL)
+		 : 0));
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
-- 
1.7.1

From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] xilinx:Remove unused variable num_frag in the function
 axienet_start_xmit
Date: Wed, 17 Jun 2015 11:52:42 -0400
Message-ID: <1434556362-3748-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 michal.simek@xilinx.com, soren.brinkmann@xilinx.com, John.Linn@xilinx.com,
 linux-arm-kernel@lists.infradead.org
To: anirudh@xilinx.com
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

This removes the unused variable num_frag and the setting of it
to the number of fragments from the passed sk_buff pointer by
this function's caller due to this variable never being used
in this particular function and is not declared as  global so
setting it for global use in this file is pointless.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 28b7e7d..624dce4 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -651,7 +651,6 @@ static inline int axienet_check_tx_bd_space(struct axienet_local *lp,
 static int axienet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	u32 ii;
-	u32 num_frag;
 	u32 csum_start_off;
 	u32 csum_index_off;
 	skb_frag_t *frag;
@@ -659,7 +658,6 @@ static int axienet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	struct axienet_local *lp = netdev_priv(ndev);
 	struct axidma_bd *cur_p;
 
-	num_frag = skb_shinfo(skb)->nr_frags;
 	cur_p = &lp->tx_bd_v[lp->tx_bd_tail];
 
 	if (axienet_check_tx_bd_space(lp, num_frag)) {
-- 
2.1.4

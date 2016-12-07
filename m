From: Zhouyi Zhou <zhouzhouyi@gmail.com>
Subject: [PATCH 1/1] ixgbe: fcoe: return value of skb_linearize should be handled
Date: Wed,  7 Dec 2016 15:43:34 +0800
Message-ID: <1481096614-25295-1-git-send-email-zhouzhouyi@gmail.com>
Cc: Zhouyi Zhou <zhouzhouyi@gmail.com>,
        Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: <jeffrey.t.kirsher@intel.com>, <intel-wired-lan@lists.osuosl.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com> 
Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c | 6 +++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 3 +--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 2a653ec..7b6bdb7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -490,7 +490,11 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 	 */
 	if ((fh->fh_r_ctl == FC_RCTL_DD_SOL_DATA) &&
 	    (fctl & FC_FC_END_SEQ)) {
-		skb_linearize(skb);
+		int err;
+
+		err = skb_linearize(skb);
+		if (err)
+			return err;
 		crc = (struct fcoe_crc_eof *)skb_put(skb, sizeof(*crc));
 		crc->fcoe_eof = FC_EOF_T;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index fee1f29..4926d48 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2173,8 +2173,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				total_rx_bytes += ddp_bytes;
 				total_rx_packets += DIV_ROUND_UP(ddp_bytes,
 								 mss);
-			}
-			if (!ddp_bytes) {
+			} else {
 				dev_kfree_skb_any(skb);
 				continue;
 			}
-- 
1.9.1

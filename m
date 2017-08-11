From: Joe Perches <joe@perches.com>
Subject: [PATCH] fm10k: Fix misuse of net_ratelimit()
Date: Fri, 11 Aug 2017 09:17:15 -0700
Message-ID: <83d6fcab6a180d7006c8eb396c9aa3169dc6a84d.1502468221.git.joe@perches.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct the backward logic using !net_ratelimit()

Miscellanea:

o Add a blank line before the error return label

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 9dffaba85ae6..489d8032e2f2 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -806,9 +806,10 @@ static int fm10k_tso(struct fm10k_ring *tx_ring,
 	tx_desc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
 
 	return 1;
+
 err_vxlan:
 	tx_ring->netdev->features &= ~NETIF_F_GSO_UDP_TUNNEL;
-	if (!net_ratelimit())
+	if (net_ratelimit())
 		netdev_err(tx_ring->netdev,
 			   "TSO requested for unsupported tunnel, disabling offload\n");
 	return -1;
-- 
2.10.0.rc2.1.g053435c

From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 17/21] net: thunderx: Don't set mac address for secondary Qset VFs
Date: Fri, 12 Aug 2016 16:51:40 +0530
Message-ID: <1471000904-21715-18-git-send-email-sunil.kovvuri@gmail.com>
References: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Set MAC addresses only for primary VF's and don't for
secondary VFs.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index dd57361..0b68f2b 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1209,7 +1209,7 @@ int nicvf_open(struct net_device *netdev)
 	}
 
 	/* Check if we got MAC address from PF or else generate a radom MAC */
-	if (is_zero_ether_addr(netdev->dev_addr)) {
+	if (!nic->sqs_mode && is_zero_ether_addr(netdev->dev_addr)) {
 		eth_hw_addr_random(netdev);
 		nicvf_hw_set_mac_addr(nic, netdev);
 	}
-- 
2.7.4

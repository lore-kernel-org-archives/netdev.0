From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V2 net 05/20] net/ena: fix RSS default hash configuration
Date: Sun,  4 Dec 2016 15:19:23 +0200
Message-ID: <1480857578-5065-6-git-send-email-netanel@annapurnalabs.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ENA default hash configure IPv4_frag hash twice instead of
configure non ip packets.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index 3066d9c..46aad3a 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -2184,7 +2184,7 @@ int ena_com_set_default_hash_ctrl(struct ena_com_dev *ena_dev)
 	hash_ctrl->selected_fields[ENA_ADMIN_RSS_IP4_FRAG].fields =
 		ENA_ADMIN_RSS_L3_SA | ENA_ADMIN_RSS_L3_DA;
 
-	hash_ctrl->selected_fields[ENA_ADMIN_RSS_IP4_FRAG].fields =
+	hash_ctrl->selected_fields[ENA_ADMIN_RSS_NOT_IP].fields =
 		ENA_ADMIN_RSS_L2_DA | ENA_ADMIN_RSS_L2_SA;
 
 	for (i = 0; i < ENA_ADMIN_RSS_PROTO_NUM; i++) {
-- 
2.7.4

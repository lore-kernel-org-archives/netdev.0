From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V3 net-next 05/14] net/ena: fix RSS default hash configuration
Date: Fri, 27 Jan 2017 00:18:07 +0200
Message-ID: <1485469096-5271-6-git-send-email-netanel@annapurnalabs.com>
References: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ENA default hash configures IPv4_frag hash twice instead of
configure non-IP packets.

The bug caused IPv4 fragmented packets to be calculated based on
L2 source and destination address instead of L3 source and destination.
IPv4 packets can reach to the wrong Rx queue.

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

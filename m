From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V4 net-next 03/13] net/ena: fix ethtool RSS flow configuration
Date: Thu,  9 Feb 2017 15:21:29 +0200
Message-ID: <1486646499-13682-4-git-send-email-netanel@annapurnalabs.com>
References: <1486646499-13682-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com,
        evgenys@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486646499-13682-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ena_flow_data_to_flow_hash and ena_flow_hash_to_flow_type
treat the ena_flow_hash_to_flow_type enum as power of two values.

Change the values of ena_admin_flow_hash_fields to be power of two values.

This bug effect the ethtool set/get rxnfc.
ethtool will report wrong values hash fields for get and will
configure wrong hash fields in set.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_admin_defs.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
index a46e749..e1594d6 100644
--- a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
+++ b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
@@ -631,22 +631,22 @@ enum ena_admin_flow_hash_proto {
 /* RSS flow hash fields */
 enum ena_admin_flow_hash_fields {
 	/* Ethernet Dest Addr */
-	ENA_ADMIN_RSS_L2_DA	= 0,
+	ENA_ADMIN_RSS_L2_DA	= BIT(0),
 
 	/* Ethernet Src Addr */
-	ENA_ADMIN_RSS_L2_SA	= 1,
+	ENA_ADMIN_RSS_L2_SA	= BIT(1),
 
 	/* ipv4/6 Dest Addr */
-	ENA_ADMIN_RSS_L3_DA	= 2,
+	ENA_ADMIN_RSS_L3_DA	= BIT(2),
 
 	/* ipv4/6 Src Addr */
-	ENA_ADMIN_RSS_L3_SA	= 5,
+	ENA_ADMIN_RSS_L3_SA	= BIT(3),
 
 	/* tcp/udp Dest Port */
-	ENA_ADMIN_RSS_L4_DP	= 6,
+	ENA_ADMIN_RSS_L4_DP	= BIT(4),
 
 	/* tcp/udp Src Port */
-	ENA_ADMIN_RSS_L4_SP	= 7,
+	ENA_ADMIN_RSS_L4_SP	= BIT(5),
 };
 
 struct ena_admin_proto_input {
-- 
2.7.4

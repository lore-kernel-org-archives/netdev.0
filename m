From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 5/6] tg3: Fix UDP fragments treated as RMCP
Date: Mon, 29 Jul 2013 13:58:39 -0700
Message-ID: <1375131520-1746-6-git-send-email-nsujir@broadcom.com>
References: <1375131520-1746-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2530 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755225Ab3G2U65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 16:58:57 -0400
In-Reply-To: <1375131520-1746-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5762 devices sometimes incorrectly treat udp fragments as RMCP
packets and route to the APE. This patch sets the RX_MODE_IPV4_FRAG_FIX
bit for these devices which enables the proper behaviour.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 3 +++
 drivers/net/ethernet/broadcom/tg3.h | 1 +
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index f077c8f..6e59ef1 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -10420,6 +10420,9 @@ static int tg3_reset_hw(struct tg3 *tp, bool reset_phy)
 	if (tg3_flag(tp, 5755_PLUS))
 		tp->rx_mode |= RX_MODE_IPV6_CSUM_ENABLE;
 
+	if (tg3_asic_rev(tp) == ASIC_REV_5762)
+		tp->rx_mode |= RX_MODE_IPV4_FRAG_FIX;
+
 	if (tg3_flag(tp, ENABLE_RSS))
 		tp->rx_mode |= RX_MODE_RSS_ENABLE |
 			       RX_MODE_RSS_ITBL_HASH_BITS_7 |
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 2e0f3d3..ddb8be1 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -532,6 +532,7 @@
 #define  RX_MODE_RSS_ITBL_HASH_BITS_7	 0x00700000
 #define  RX_MODE_RSS_ENABLE		 0x00800000
 #define  RX_MODE_IPV6_CSUM_ENABLE	 0x01000000
+#define  RX_MODE_IPV4_FRAG_FIX		 0x02000000
 #define MAC_RX_STATUS			0x0000046c
 #define  RX_STATUS_REMOTE_TX_XOFFED	 0x00000001
 #define  RX_STATUS_XOFF_RCVD		 0x00000002
-- 
1.8.1.4

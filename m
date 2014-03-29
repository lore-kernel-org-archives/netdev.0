From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 02/17] atl1c: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:26:15 +0100
Message-ID: <7af8c421a3153f24b105d00acc7922e1ad823535.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60857 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbaC2L0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 07:26:50 -0400
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 31f2623..e11bf18 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1973,17 +1973,17 @@ static int atl1c_tso_csum(struct atl1c_adapter *adapter,
 			  enum atl1c_trans_queue type)
 {
 	struct pci_dev *pdev = adapter->pdev;
+	unsigned short offload_type;
 	u8 hdr_len;
 	u32 real_len;
-	unsigned short offload_type;
-	int err;
 
 	if (skb_is_gso(skb)) {
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (unlikely(err))
-				return -1;
-		}
+		int err;
+
+		err = skb_cow_head(skb, 0);
+		if (err < 0)
+			return err;
+
 		offload_type = skb_shinfo(skb)->gso_type;
 
 		if (offload_type & SKB_GSO_TCPV4) {
-- 
1.9.0

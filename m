From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 06/17] ixgbvf: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:26:19 +0100
Message-ID: <3c17d6be148052aa3d3dcc31197e833fa5c20b5b.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60866 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbaC2L0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 07:26:51 -0400
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index b7ab03a..d608599 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1910,20 +1910,18 @@ static int igbvf_tso(struct igbvf_adapter *adapter,
                      struct sk_buff *skb, u32 tx_flags, u8 *hdr_len)
 {
 	struct e1000_adv_tx_context_desc *context_desc;
-	unsigned int i;
-	int err;
 	struct igbvf_buffer *buffer_info;
 	u32 info = 0, tu_cmd = 0;
 	u32 mss_l4len_idx, l4len;
+	unsigned int i;
+	int err;
+
 	*hdr_len = 0;
 
-	if (skb_header_cloned(skb)) {
-		err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (err) {
-			dev_err(&adapter->pdev->dev,
-			        "igbvf_tso returning an error\n");
-			return err;
-		}
+	err = skb_cow_head(skb, 0);
+	if (err < 0) {
+		dev_err(&adapter->pdev->dev, "igbvf_tso returning an error\n");
+		return err;
 	}
 
 	l4len = tcp_hdrlen(skb);
-- 
1.9.0

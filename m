From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 09/17] e1000: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:26:22 +0100
Message-ID: <5317eb48fee5ca58a806268ebb7726924d926834.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60868 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbaC2L0v (ORCPT
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
 drivers/net/ethernet/intel/e1000/e1000_main.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 46e6544..27058df 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2682,14 +2682,13 @@ static int e1000_tso(struct e1000_adapter *adapter,
 	u32 cmd_length = 0;
 	u16 ipcse = 0, tucse, mss;
 	u8 ipcss, ipcso, tucss, tucso, hdr_len;
-	int err;
 
 	if (skb_is_gso(skb)) {
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (err)
-				return err;
-		}
+		int err;
+
+		err = skb_cow_head(skb, 0);
+		if (err < 0)
+			return err;
 
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		mss = skb_shinfo(skb)->gso_size;
-- 
1.9.0

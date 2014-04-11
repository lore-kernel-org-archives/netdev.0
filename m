From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 08/13] igb: remove open-coded skb_cow_head
Date: Fri, 11 Apr 2014 06:52:58 -0700
Message-ID: <1397224383-19269-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35182 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758742AbaDKNxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 09:53:12 -0400
In-Reply-To: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 3019818..720ad12 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4605,6 +4605,7 @@ static int igb_tso(struct igb_ring *tx_ring,
 	struct sk_buff *skb = first->skb;
 	u32 vlan_macip_lens, type_tucmd;
 	u32 mss_l4len_idx, l4len;
+	int err;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		return 0;
@@ -4612,11 +4613,9 @@ static int igb_tso(struct igb_ring *tx_ring,
 	if (!skb_is_gso(skb))
 		return 0;
 
-	if (skb_header_cloned(skb)) {
-		int err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (err)
-			return err;
-	}
+	err = skb_cow_head(skb, 0);
+	if (err < 0)
+		return err;
 
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 	type_tucmd = E1000_ADVTXD_TUCMD_L4T_TCP;
-- 
1.9.0

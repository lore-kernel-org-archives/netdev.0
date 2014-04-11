From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 12/13] i40evf: remove open-coded skb_cow_head
Date: Fri, 11 Apr 2014 06:53:02 -0700
Message-ID: <1397224383-19269-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24548 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758771AbaDKNxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 09:53:14 -0400
In-Reply-To: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 53be5f4..b9f50f4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1114,20 +1114,18 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		    u64 *cd_type_cmd_tso_mss, u32 *cd_tunneling)
 {
 	u32 cd_cmd, cd_tso_len, cd_mss;
+	struct ipv6hdr *ipv6h;
 	struct tcphdr *tcph;
 	struct iphdr *iph;
 	u32 l4len;
 	int err;
-	struct ipv6hdr *ipv6h;
 
 	if (!skb_is_gso(skb))
 		return 0;
 
-	if (skb_header_cloned(skb)) {
-		err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (err)
-			return err;
-	}
+	err = skb_cow_head(skb, 0);
+	if (err < 0)
+		return err;
 
 	if (protocol == htons(ETH_P_IP)) {
 		iph = skb->encapsulation ? inner_ip_hdr(skb) : ip_hdr(skb);
-- 
1.9.0

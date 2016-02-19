From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/16] i40e/i40evf: Use u64 values instead of casting them in TSO function
Date: Thu, 18 Feb 2016 16:31:07 -0800
Message-ID: <1455841881-128892-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49646 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965452AbcBSAbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 19:31:23 -0500
In-Reply-To: <1455841881-128892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

Instead of casing u32 values to u64 it makes more sense to just start out
with u64 values in the first place.  This way we don't need to create a
mess with all of the casts needed to populate a 64b value.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 9 ++++-----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 9 ++++-----
 2 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index d4364ec..5e82589 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2267,7 +2267,7 @@ out:
 static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		    u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 {
-	u32 cd_cmd, cd_tso_len, cd_mss;
+	u64 cd_cmd, cd_tso_len, cd_mss;
 	struct ipv6hdr *ipv6h;
 	struct tcphdr *tcph;
 	struct iphdr *iph;
@@ -2309,10 +2309,9 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	cd_cmd = I40E_TX_CTX_DESC_TSO;
 	cd_tso_len = skb->len - *hdr_len;
 	cd_mss = skb_shinfo(skb)->gso_size;
-	*cd_type_cmd_tso_mss |= ((u64)cd_cmd << I40E_TXD_CTX_QW1_CMD_SHIFT) |
-				((u64)cd_tso_len <<
-				 I40E_TXD_CTX_QW1_TSO_LEN_SHIFT) |
-				((u64)cd_mss << I40E_TXD_CTX_QW1_MSS_SHIFT);
+	*cd_type_cmd_tso_mss |= (cd_cmd << I40E_TXD_CTX_QW1_CMD_SHIFT) |
+				(cd_tso_len << I40E_TXD_CTX_QW1_TSO_LEN_SHIFT) |
+				(cd_mss << I40E_TXD_CTX_QW1_MSS_SHIFT);
 	return 1;
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 8b20ed3..c5f98cb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1527,7 +1527,7 @@ out:
 static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		    u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 {
-	u32 cd_cmd, cd_tso_len, cd_mss;
+	u64 cd_cmd, cd_tso_len, cd_mss;
 	struct ipv6hdr *ipv6h;
 	struct tcphdr *tcph;
 	struct iphdr *iph;
@@ -1569,10 +1569,9 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	cd_cmd = I40E_TX_CTX_DESC_TSO;
 	cd_tso_len = skb->len - *hdr_len;
 	cd_mss = skb_shinfo(skb)->gso_size;
-	*cd_type_cmd_tso_mss |= ((u64)cd_cmd << I40E_TXD_CTX_QW1_CMD_SHIFT) |
-				((u64)cd_tso_len <<
-				 I40E_TXD_CTX_QW1_TSO_LEN_SHIFT) |
-				((u64)cd_mss << I40E_TXD_CTX_QW1_MSS_SHIFT);
+	*cd_type_cmd_tso_mss |= (cd_cmd << I40E_TXD_CTX_QW1_CMD_SHIFT) |
+				(cd_tso_len << I40E_TXD_CTX_QW1_TSO_LEN_SHIFT) |
+				(cd_mss << I40E_TXD_CTX_QW1_MSS_SHIFT);
 	return 1;
 }
 
-- 
2.5.0

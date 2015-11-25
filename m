From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/16] i40e/i40evf: remove unused tunnel parameter
Date: Tue, 24 Nov 2015 16:04:32 -0800
Message-ID: <1448409886-90686-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23956 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752375AbbKYAEt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 19:04:49 -0500
In-Reply-To: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Code was moved into a separate function some time ago.

Change-ID: Icabbe71ce05cf5d716d3e1152cdd9cd41d11bcb5
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 11 ++++-------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |  8 +++-----
 2 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 6649ce4..98680b6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2186,14 +2186,12 @@ out:
  * @tx_ring:  ptr to the ring to send
  * @skb:      ptr to the skb we're sending
  * @hdr_len:  ptr to the size of the packet header
- * @cd_type_cmd_tso_mss: ptr to u64 object
- * @cd_tunneling: ptr to context descriptor bits
+ * @cd_type_cmd_tso_mss: Quad Word 1
  *
  * Returns 0 if no TSO can happen, 1 if tso is going, or error
  **/
 static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
-		    u8 *hdr_len, u64 *cd_type_cmd_tso_mss,
-		    u32 *cd_tunneling)
+		    u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 {
 	u32 cd_cmd, cd_tso_len, cd_mss;
 	struct ipv6hdr *ipv6h;
@@ -2246,7 +2244,7 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
  * @tx_ring:  ptr to the ring to send
  * @skb:      ptr to the skb we're sending
  * @tx_flags: the collected send information
- * @cd_type_cmd_tso_mss: ptr to u64 object
+ * @cd_type_cmd_tso_mss: Quad Word 1
  *
  * Returns 0 if no Tx timestamp can happen and 1 if the timestamp will happen
  **/
@@ -2825,8 +2823,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	else if (protocol == htons(ETH_P_IPV6))
 		tx_flags |= I40E_TX_FLAGS_IPV6;
 
-	tso = i40e_tso(tx_ring, skb, &hdr_len,
-		       &cd_type_cmd_tso_mss, &cd_tunneling);
+	tso = i40e_tso(tx_ring, skb, &hdr_len, &cd_type_cmd_tso_mss);
 
 	if (tso < 0)
 		goto out_drop;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 77968b1..a4eea08 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1436,13 +1436,12 @@ out:
  * @tx_ring:  ptr to the ring to send
  * @skb:      ptr to the skb we're sending
  * @hdr_len:  ptr to the size of the packet header
- * @cd_tunneling: ptr to context descriptor bits
+ * @cd_type_cmd_tso_mss: Quad Word 1
  *
  * Returns 0 if no TSO can happen, 1 if tso is going, or error
  **/
 static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
-		    u8 *hdr_len, u64 *cd_type_cmd_tso_mss,
-		    u32 *cd_tunneling)
+		    u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 {
 	u32 cd_cmd, cd_tso_len, cd_mss;
 	struct ipv6hdr *ipv6h;
@@ -1979,8 +1978,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	else if (protocol == htons(ETH_P_IPV6))
 		tx_flags |= I40E_TX_FLAGS_IPV6;
 
-	tso = i40e_tso(tx_ring, skb, &hdr_len,
-		       &cd_type_cmd_tso_mss, &cd_tunneling);
+	tso = i40e_tso(tx_ring, skb, &hdr_len, &cd_type_cmd_tso_mss);
 
 	if (tso < 0)
 		goto out_drop;
-- 
2.5.0

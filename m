From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: do TSO only if CHECKSUM_PARTIAL is set
Date: Wed, 17 Feb 2016 09:51:35 -0800
Message-ID: <1455731506-62165-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17063 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161610AbcBQRvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:51:50 -0500
In-Reply-To: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Don't bother trying to set up a TSO if the skb->ip_summed is not
set to CHECKSUM_PARTIAL.

Change-ID: I6495b3568e404907a2965b48cf3e2effa7c9ab55
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 3 +++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index f2e6afc..15130b5d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2221,6 +2221,9 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	u32 l4len;
 	int err;
 
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
 	if (!skb_is_gso(skb))
 		return 0;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 69fb85f..4205aef 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1471,6 +1471,9 @@ static int i40e_tso(struct i40e_ring *tx_ring, struct sk_buff *skb,
 	u32 l4len;
 	int err;
 
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
 	if (!skb_is_gso(skb))
 		return 0;
 
-- 
2.5.0

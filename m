From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  06/11] ixgbevf: add ixgbevf_rx_skb
Date: Tue, 29 Oct 2013 05:02:26 -0700
Message-ID: <1383048151-15002-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:19420 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754650Ab3J2MCk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 08:02:40 -0400
In-Reply-To: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch adds ixgbevf_rx_skb in line with how ixgbe handles the variations on
how packets can be received. It will be extended in a following patch for
CONFIG_NET_RX_BUSY_POLL support.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 87279c8a..a2cc6bb 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -300,6 +300,20 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
 }
 
 /**
+ * ixgbevf_rx_skb - Helper function to determine proper Rx method
+ * @q_vector: structure containing interrupt and ring information
+ * @skb: packet to send up
+ * @status: hardware indication of status of receive
+ * @rx_desc: rx descriptor
+ **/
+static void ixgbevf_rx_skb(struct ixgbevf_q_vector *q_vector,
+			   struct sk_buff *skb, u8 status,
+			   union ixgbe_adv_rx_desc *rx_desc)
+{
+	ixgbevf_receive_skb(q_vector, skb, status, rx_desc);
+}
+
+/**
  * ixgbevf_rx_checksum - indicate in skb if hw indicated a good cksum
  * @ring: pointer to Rx descriptor ring structure
  * @status_err: hardware indication of status of receive
@@ -494,7 +508,7 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 			goto next_desc;
 		}
 
-		ixgbevf_receive_skb(q_vector, skb, staterr, rx_desc);
+		ixgbevf_rx_skb(q_vector, skb, staterr, rx_desc);
 
 next_desc:
 		rx_desc->wb.upper.status_error = 0;
-- 
1.8.3.1

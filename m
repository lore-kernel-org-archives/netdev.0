From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 10/13] igbvf: remove open-coded skb_cow_head
Date: Fri, 11 Apr 2014 06:53:00 -0700
Message-ID: <1397224383-19269-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47069 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755788AbaDKNxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 09:53:13 -0400
In-Reply-To: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 4/5] iwlwifi: use reset to set transport header
Date: Fri,  2 Dec 2016 09:51:06 +0800
Message-ID: <1480643467-4420-5-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:24763 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756341AbcLBBvU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 20:51:20 -0500
In-Reply-To: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since offset is zero, it's not necessary to use set function. Reset
function is straightforward, and will remove the unnecessary add
operation in set function.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/pcie/tx.c b/drivers/net/wireless/intel/iwlwifi/pcie/tx.c
index 5f840f1..e44e5ad 100644
--- a/drivers/net/wireless/intel/iwlwifi/pcie/tx.c
+++ b/drivers/net/wireless/intel/iwlwifi/pcie/tx.c
@@ -2196,7 +2196,7 @@ static int iwl_fill_data_tbs_amsdu(struct iwl_trans *trans, struct sk_buff *skb,
 
 			memcpy(skb_put(csum_skb, tcp_hdrlen(skb)),
 			       tcph, tcp_hdrlen(skb));
-			skb_set_transport_header(csum_skb, 0);
+			skb_reset_transport_header(csum_skb);
 			csum_skb->csum_start =
 				(unsigned char *)tcp_hdr(csum_skb) -
 						 csum_skb->head;
-- 
1.8.3.1

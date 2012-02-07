From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] e1000e: fix checkpatch warning from MINMAX test
Date: Tue,  7 Feb 2012 04:33:56 -0800
Message-ID: <1328618038-5008-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47275 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756151Ab2BGMeP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 07:34:15 -0500
In-Reply-To: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

WARNING: min() should probably be min_t(unsigned int, 4, skb->data_len)

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 02efae0..a9f25fc 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5023,7 +5023,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 		if (skb->data_len && (hdr_len == len)) {
 			unsigned int pull_size;
 
-			pull_size = min((unsigned int)4, skb->data_len);
+			pull_size = min_t(unsigned int, 4, skb->data_len);
 			if (!__pskb_pull_tail(skb, pull_size)) {
 				e_err("__pskb_pull_tail failed.\n");
 				dev_kfree_skb_any(skb);
-- 
1.7.7.6

From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 5/6] ixgbevf: fix handling of tx checksumming
Date: Thu, 27 Feb 2014 20:32:44 -0800
Message-ID: <1393561965-3688-6-git-send-email-aaron.f.brown@intel.com>
References: <1393561965-3688-1-git-send-email-aaron.f.brown@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:46050 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751172AbaB1EgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 23:36:10 -0500
In-Reply-To: <1393561965-3688-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch resolves an issue introduced by:
commit 7ad1a093519e37fb673579819bf6af122641c397
ixgbevf: make the first tx_buffer a repository for most of the skb info

Incorrect check for the result of ixgbevf_tso() can lead to calling
ixgbevf_tx_csum() which can spawn 2 context descriptors and result in
performance degradation and/or corrupted packets.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a6af7b7..79023ba 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3155,7 +3155,7 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	tso = ixgbevf_tso(tx_ring, first, &hdr_len);
 	if (tso < 0)
 		goto out_drop;
-	else
+	else if (!tso)
 		ixgbevf_tx_csum(tx_ring, first);
 
 	ixgbevf_tx_map(tx_ring, first, hdr_len);
-- 
1.8.5.GIT

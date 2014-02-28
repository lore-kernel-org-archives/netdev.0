From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 6/6] ixgbevf: add check for CHECKSUM_PARTIAL when doing TSO
Date: Thu, 27 Feb 2014 20:32:45 -0800
Message-ID: <1393561965-3688-7-git-send-email-aaron.f.brown@intel.com>
References: <1393561965-3688-1-git-send-email-aaron.f.brown@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13228 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750907AbaB1EgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 23:36:11 -0500
In-Reply-To: <1393561965-3688-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch adds check for CHECKSUM_PARTIAL to avoid the skb_is_gso check
in ixgbevf_tso(). It should reduce overhead for workloads that are not using
TSO or checksum offloads. It is the same as in ixgbe.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 79023ba..57e0cd8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2777,6 +2777,9 @@ static int ixgbevf_tso(struct ixgbevf_ring *tx_ring,
 	u32 vlan_macip_lens, type_tucmd;
 	u32 mss_l4len_idx, l4len;
 
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
 	if (!skb_is_gso(skb))
 		return 0;
 
-- 
1.8.5.GIT

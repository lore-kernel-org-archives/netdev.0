From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 6/8] ixgbe: fix RSS limit for X550
Date: Tue, 29 Dec 2015 19:23:27 -0800
Message-ID: <1451445809-70497-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1451445809-70497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59463 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754050AbbL3DXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 22:23:36 -0500
In-Reply-To: <1451445809-70497-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

X550 allows for up to 64 RSS queues, but the driver can have max
of 63 (-1 MSIX vector for link).

On systems with >= 64 CPUs the driver will set the redirection table
for all 64 queues which will result in packets being dropped.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index f4c9a42..4b9156c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -317,7 +317,7 @@ enum ixgbe_ring_f_enum {
 };
 
 #define IXGBE_MAX_RSS_INDICES		16
-#define IXGBE_MAX_RSS_INDICES_X550	64
+#define IXGBE_MAX_RSS_INDICES_X550	63
 #define IXGBE_MAX_VMDQ_INDICES		64
 #define IXGBE_MAX_FDIR_INDICES		63	/* based on q_vector limit */
 #define IXGBE_MAX_FCOE_INDICES		8
-- 
2.5.0

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/11] ixgbevf: fix size of queue stats length
Date: Thu, 20 Apr 2017 18:50:24 -0700
Message-ID: <20170421015029.18994-7-jeffrey.t.kirsher@intel.com>
References: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:53037 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034423AbdDUBu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 21:50:59 -0400
In-Reply-To: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

IXGBEVF_QUEUE_STATS_LEN is based on ixgebvf_stats, not ixgbe_stats.

This change fixes a bug where ethtool -S displayed some empty fields.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index 6bf740945260..43b70cd55bc6 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -80,7 +80,7 @@ static struct ixgbe_stats ixgbevf_gstrings_stats[] = {
 #define IXGBEVF_QUEUE_STATS_LEN ( \
 	(((struct ixgbevf_adapter *)netdev_priv(netdev))->num_tx_queues + \
 	 ((struct ixgbevf_adapter *)netdev_priv(netdev))->num_rx_queues) * \
-	 (sizeof(struct ixgbe_stats) / sizeof(u64)))
+	 (sizeof(struct ixgbevf_stats) / sizeof(u64)))
 #define IXGBEVF_GLOBAL_STATS_LEN ARRAY_SIZE(ixgbevf_gstrings_stats)
 
 #define IXGBEVF_STATS_LEN (IXGBEVF_GLOBAL_STATS_LEN + IXGBEVF_QUEUE_STATS_LEN)
-- 
2.12.2

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 06/12] ixgbe: remove ntuple display support
Date: Wed, 27 Apr 2011 02:34:45 -0700
Message-ID: <1303896891-16006-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40049 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756070Ab1D0JfA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 05:35:00 -0400
In-Reply-To: <1303896891-16006-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change removes the ntuple display support from ixgbe.  The reason for
this change is to resolve a number of issues in the way display filtering
is handled.

I plan to add support for displaying these filters via the network flow
classifier interface.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |    3 ---
 drivers/net/ixgbe/ixgbe_main.c    |    3 ---
 2 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 5005a36..6cf1c71 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1030,9 +1030,6 @@ static int ixgbe_get_sset_count(struct net_device *netdev, int sset)
 		return IXGBE_TEST_LEN;
 	case ETH_SS_STATS:
 		return IXGBE_STATS_LEN;
-	case ETH_SS_NTUPLE_FILTERS:
-		return ETHTOOL_MAX_NTUPLE_LIST_ENTRY *
-		       ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY;
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 200ae7e..dbe29e5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4203,9 +4203,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 		break;
 	}
 
-	/* clear n-tuple filters that are cached */
-	ethtool_ntuple_flush(netdev);
-
 	if (!pci_channel_offline(adapter->pdev))
 		ixgbe_reset(adapter);
 
-- 
1.7.4.4


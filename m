From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] ixgbe: fix potential null dereference
Date: Tue,  5 Feb 2013 02:02:24 -0800
Message-ID: <1360058548-18158-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Josh Hay <joshua.a.hay@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19489 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753803Ab3BEKCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2013 05:02:52 -0500
In-Reply-To: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hay <joshua.a.hay@intel.com>

This patch adds a default case which goes to the next loop iteration
in the case where p is not set, preventing p from being dereferenced.

Signed-off-by: Josh Hay <joshua.a.hay@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 216203e..bafd141 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1040,6 +1040,9 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 			p = (char *) adapter +
 					ixgbe_gstrings_stats[i].stat_offset;
 			break;
+		default:
+			data[i] = 0;
+			continue;
 		}
 
 		data[i] = (ixgbe_gstrings_stats[i].sizeof_stat ==
-- 
1.7.11.7

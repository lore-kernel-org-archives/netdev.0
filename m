From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/16] i40e: Setting queue count to 1 using ethtool is valid
Date: Fri, 10 Jan 2014 00:58:47 -0800
Message-ID: <1389344336-1558-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389344336-1558-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50715 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751592AbaAJI7F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 03:59:05 -0500
In-Reply-To: <1389344336-1558-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Fix a bug where ethtool set-channels would return failure when configuring
only one Rx queue.

Change-ID: Id833c48c17d71e352b30f3249f6acf9e7aaec57e
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index b886ee5..342a6e1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1634,7 +1634,7 @@ static int i40e_set_channels(struct net_device *dev,
 	 * class queue mapping
 	 */
 	new_count = i40e_reconfig_rss_queues(pf, count);
-	if (new_count > 1)
+	if (new_count > 0)
 		return 0;
 	else
 		return -EINVAL;
-- 
1.8.3.1

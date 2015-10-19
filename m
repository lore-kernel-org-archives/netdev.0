From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 14/17] i40e: Move error message to debug level
Date: Mon, 19 Oct 2015 15:49:28 -0700
Message-ID: <1445294971-44714-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9921 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301AbbJSWth (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 18:49:37 -0400
In-Reply-To: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

There is an error coming back from get_phy_capabilities that does not
seem to have any functional implications. We will continue looking into
why this error message is occurring, but in the meantime, we will move it
to debug to avoid confusion.

Change-ID: I9091754bf62c066ddedeb249923d85606e2d68ed
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 6e5f931..8fd26fd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -751,9 +751,9 @@ static int i40e_set_settings(struct net_device *netdev,
 
 		status = i40e_update_link_info(hw);
 		if (status)
-			netdev_info(netdev, "Updating link info failed with err %s aq_err %s\n",
-				    i40e_stat_str(hw, status),
-				    i40e_aq_str(hw, hw->aq.asq_last_status));
+			netdev_dbg(netdev, "Updating link info failed with err %s aq_err %s\n",
+				   i40e_stat_str(hw, status),
+				   i40e_aq_str(hw, hw->aq.asq_last_status));
 
 	} else {
 		netdev_info(netdev, "Nothing changed, exiting without setting anything.\n");
-- 
2.4.3

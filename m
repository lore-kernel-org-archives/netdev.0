From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: Allow user to change link settings if link is down
Date: Fri, 29 Aug 2014 02:30:07 -0700
Message-ID: <1409304620-23251-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53236 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752074AbaH2JaY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 05:30:24 -0400
In-Reply-To: <1409304620-23251-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Allow the user to change auto-negotiation and speed settings if
link is down.

Change-ID: I372967c627682b5e1835f623a7cbf41b21b51043
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index e701f42..de4ce0e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -466,7 +466,8 @@ static int i40e_set_settings(struct net_device *netdev,
 
 	if (hw->phy.media_type != I40E_MEDIA_TYPE_BASET &&
 	    hw->phy.media_type != I40E_MEDIA_TYPE_FIBER &&
-	    hw->phy.media_type != I40E_MEDIA_TYPE_BACKPLANE)
+	    hw->phy.media_type != I40E_MEDIA_TYPE_BACKPLANE &&
+	    hw->phy.link_info.link_info & I40E_AQ_LINK_UP)
 		return -EOPNOTSUPP;
 
 	/* get our own copy of the bits to check against */
-- 
1.9.3

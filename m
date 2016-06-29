From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/16] i40e: fix missing DA cable check
Date: Tue, 28 Jun 2016 21:40:54 -0700
Message-ID: <1467175262-54719-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Serey Kong <serey.kong@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62810 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbcF2EnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:18 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serey Kong <serey.kong@intel.com>

When a Direct Attach (DA) cable is used, if the i40e_set_settings
function is called it would return an error. Add the DA type so
the function won't fail.

Change-ID: I2b802f27a5d91cfefa72fd1f852acb4d74647a8e
Signed-off-by: Serey Kong <serey.kong@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 5e8d84f..8381dab 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -663,6 +663,7 @@ static int i40e_set_settings(struct net_device *netdev,
 	if (hw->phy.media_type != I40E_MEDIA_TYPE_BASET &&
 	    hw->phy.media_type != I40E_MEDIA_TYPE_FIBER &&
 	    hw->phy.media_type != I40E_MEDIA_TYPE_BACKPLANE &&
+	    hw->phy.media_type != I40E_MEDIA_TYPE_DA &&
 	    hw->phy.link_info.link_info & I40E_AQ_LINK_UP)
 		return -EOPNOTSUPP;
 
-- 
2.5.5

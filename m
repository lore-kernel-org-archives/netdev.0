From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40evf: don't lie to ethtool
Date: Wed, 21 May 2014 05:01:04 -0700
Message-ID: <1400673673-31626-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:21038 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752332AbaEUMB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:28 -0400
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Don't tell ethtool that the VF can do 10GbaseT, when it really has no
idea what its link speed is. Set the supported values to 0 instead.
Suggested by Ben Hutchings.

CC: Ben Hutchings <ben@decadent.org.uk>
Change-ID: Iceb0d8af68fe5d8dc13224366979ba701ba89c39
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 3566e73..b0f6270 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -80,7 +80,7 @@ static int i40evf_get_settings(struct net_device *netdev,
 	/* In the future the VF will be able to query the PF for
 	 * some information - for now use a dummy value
 	 */
-	ecmd->supported = SUPPORTED_10000baseT_Full;
+	ecmd->supported = 0;
 	ecmd->autoneg = AUTONEG_DISABLE;
 	ecmd->transceiver = XCVR_DUMMY1;
 	ecmd->port = PORT_NONE;
-- 
1.9.0

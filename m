From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 20/20] i40e: add 100Mb ethtool reporting
Date: Thu,  4 Feb 2016 03:49:11 -0800
Message-ID: <1454586551-35919-21-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28296 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965744AbcBDLt0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:26 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Add some missing reporting/advertisement of 100Mb capability
for adapters that support it.

Change-ID: I8b8523fbdc99517bec29d90c71b3744db11542ac
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 4 ++++
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 3 ++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 8a3f93d..4549591 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -411,6 +411,10 @@ static void i40e_get_settings_link_down(struct i40e_hw *hw,
 		if (pf->hw.mac.type == I40E_MAC_X722) {
 			ecmd->supported |= SUPPORTED_100baseT_Full;
 			ecmd->advertising |= ADVERTISED_100baseT_Full;
+			if (pf->flags & I40E_FLAG_100M_SGMII_CAPABLE) {
+				ecmd->supported |= SUPPORTED_100baseT_Full;
+				ecmd->advertising |= ADVERTISED_100baseT_Full;
+			}
 		}
 	}
 	if (phy_types & I40E_CAP_PHY_TYPE_XAUI ||
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3e482bc..bad4577 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8453,7 +8453,8 @@ static int i40e_sw_init(struct i40e_pf *pf)
 			     I40E_FLAG_OUTER_UDP_CSUM_CAPABLE |
 			     I40E_FLAG_WB_ON_ITR_CAPABLE |
 			     I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE |
-			     I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
+			     I40E_FLAG_GENEVE_OFFLOAD_CAPABLE |
+			     I40E_FLAG_100M_SGMII_CAPABLE;
 	}
 	pf->eeprom_version = 0xDEAD;
 	pf->lan_veb = I40E_NO_VEB;
-- 
2.5.0

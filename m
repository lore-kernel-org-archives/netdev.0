From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/17] i40e: priv flag for controlling VEB stats
Date: Fri, 16 Oct 2015 05:10:17 -0700
Message-ID: <1444997425-3396-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:51464 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751868AbbJPMK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 08:10:29 -0400
In-Reply-To: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add an ethtool priv flag to enable and disable printing
the VEB statistics.

Change-ID: I7654054a3a73b08aa8310d94ee8fce6219107dd8
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         | 1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 7aaead3..1125464 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -103,6 +103,7 @@
 #define I40E_PRIV_FLAGS_NPAR_FLAG	BIT(0)
 #define I40E_PRIV_FLAGS_LINKPOLL_FLAG	BIT(1)
 #define I40E_PRIV_FLAGS_FD_ATR		BIT(2)
+#define I40E_PRIV_FLAGS_VEB_STATS	BIT(3)
 
 #define I40E_NVM_VERSION_LO_SHIFT  0
 #define I40E_NVM_VERSION_LO_MASK   (0xff << I40E_NVM_VERSION_LO_SHIFT)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 5fe8ac0..cb88e7a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -229,6 +229,7 @@ static const char i40e_priv_flags_strings[][ETH_GSTRING_LEN] = {
 	"NPAR",
 	"LinkPolling",
 	"flow-director-atr",
+	"veb-stats",
 };
 
 #define I40E_PRIV_FLAGS_STR_LEN ARRAY_SIZE(i40e_priv_flags_strings)
@@ -2670,6 +2671,8 @@ static u32 i40e_get_priv_flags(struct net_device *dev)
 		I40E_PRIV_FLAGS_LINKPOLL_FLAG : 0;
 	ret_flags |= pf->flags & I40E_FLAG_FD_ATR_ENABLED ?
 		I40E_PRIV_FLAGS_FD_ATR : 0;
+	ret_flags |= pf->flags & I40E_FLAG_VEB_STATS_ENABLED ?
+		I40E_PRIV_FLAGS_VEB_STATS : 0;
 
 	return ret_flags;
 }
@@ -2701,6 +2704,11 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 		pf->auto_disable_flags |= I40E_FLAG_FD_ATR_ENABLED;
 	}
 
+	if (flags & I40E_PRIV_FLAGS_VEB_STATS)
+		pf->flags |= I40E_FLAG_VEB_STATS_ENABLED;
+	else
+		pf->flags &= ~I40E_FLAG_VEB_STATS_ENABLED;
+
 	return 0;
 }
 
-- 
2.4.3

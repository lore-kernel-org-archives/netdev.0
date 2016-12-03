From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 17/18] i40e/i40evf: replace for memcpy with single memcpy call in ethtool
Date: Sat,  3 Dec 2016 01:19:29 -0800
Message-ID: <20161203091930.14268-18-jeffrey.t.kirsher@intel.com>
References: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:52572 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751437AbcLCJUe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 04:20:34 -0500
In-Reply-To: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

memcpy replaced with single memcpy call in ethtool.

Change-ID: I3f5bef6bcc593412c56592c6459784db41575a0a
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 24 ++++++++----------------
 1 file changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 9500e7b..76753e1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1536,10 +1536,8 @@ static void i40e_get_strings(struct net_device *netdev, u32 stringset,
 
 	switch (stringset) {
 	case ETH_SS_TEST:
-		for (i = 0; i < I40E_TEST_LEN; i++) {
-			memcpy(data, i40e_gstrings_test[i], ETH_GSTRING_LEN);
-			data += ETH_GSTRING_LEN;
-		}
+		memcpy(data, i40e_gstrings_test,
+		       I40E_TEST_LEN * ETH_GSTRING_LEN);
 		break;
 	case ETH_SS_STATS:
 		for (i = 0; i < I40E_NETDEV_STATS_LEN; i++) {
@@ -1623,18 +1621,12 @@ static void i40e_get_strings(struct net_device *netdev, u32 stringset,
 		/* BUG_ON(p - data != I40E_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
 	case ETH_SS_PRIV_FLAGS:
-		for (i = 0; i < I40E_PRIV_FLAGS_STR_LEN; i++) {
-			memcpy(data, i40e_priv_flags_strings[i],
-			       ETH_GSTRING_LEN);
-			data += ETH_GSTRING_LEN;
-		}
-		if (pf->hw.pf_id == 0) {
-			for (i = 0; i < I40E_GL_PRIV_FLAGS_STR_LEN; i++) {
-				memcpy(data, i40e_gl_priv_flags_strings[i],
-				       ETH_GSTRING_LEN);
-				data += ETH_GSTRING_LEN;
-			}
-		}
+		memcpy(data, i40e_priv_flags_strings,
+		       I40E_PRIV_FLAGS_STR_LEN * ETH_GSTRING_LEN);
+		data += I40E_PRIV_FLAGS_STR_LEN * ETH_GSTRING_LEN;
+		if (pf->hw.pf_id == 0)
+			memcpy(data, i40e_gl_priv_flags_strings,
+			       I40E_GL_PRIV_FLAGS_STR_LEN * ETH_GSTRING_LEN);
 		break;
 	default:
 		break;
-- 
2.9.3

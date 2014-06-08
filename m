From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e/i40evf: Clean up a few things
Date: Sun,  8 Jun 2014 07:33:45 -0700
Message-ID: <1402238037-20661-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64912 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753475AbaFHOeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 10:34:03 -0400
In-Reply-To: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

1. There is no ixgbe_watchdog_task function in the driver, so change
   the comment to the correct function name, i40e_watchdog_subtask.
2. Remove num_msix_entries from interrupt set_up routine
   because it is never used.
3. Remove some TBD comments that are not needed.

Change-ID: I37697a04007074b797f85fd83d626672e4df1ad1
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h            | 1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c       | 4 +---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h   | 4 ----
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h | 4 ----
 4 files changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 9c27d8b..dc6d7c6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -201,7 +201,6 @@ struct i40e_pf {
 	unsigned long state;
 	unsigned long link_check_timeout;
 	struct msix_entry *msix_entries;
-	u16 num_msix_entries;
 	bool fc_autoneg_status;
 
 	u16 eeprom_version;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 63147a6..00fdc30 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -397,7 +397,7 @@ static struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
 	}
 	rcu_read_unlock();
 
-	/* following stats updated by ixgbe_watchdog_task() */
+	/* following stats updated by i40e_watchdog_subtask() */
 	stats->multicast	= vsi_stats->multicast;
 	stats->tx_errors	= vsi_stats->tx_errors;
 	stats->tx_dropped	= vsi_stats->tx_dropped;
@@ -6139,8 +6139,6 @@ static int i40e_reserve_msix_vectors(struct i40e_pf *pf, int vectors)
 		vectors = 0;
 	}
 
-	pf->num_msix_entries = vectors;
-
 	return vectors;
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
index 22a1b69..70951d2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl.h
@@ -341,10 +341,6 @@ struct i40e_virtchnl_pf_event {
 	int severity;
 };
 
-/* The following are TBD, not necessary for LAN functionality.
- * I40E_VIRTCHNL_OP_FCOE
- */
-
 /* VF reset states - these are written into the RSTAT register:
  * I40E_VFGEN_RSTAT1 on the PF
  * I40E_VFGEN_RSTAT on the VF
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
index 1ef5b31..cd18d56 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h
@@ -341,10 +341,6 @@ struct i40e_virtchnl_pf_event {
 	int severity;
 };
 
-/* The following are TBD, not necessary for LAN functionality.
- * I40E_VIRTCHNL_OP_FCOE
- */
-
 /* VF reset states - these are written into the RSTAT register:
  * I40E_VFGEN_RSTAT1 on the PF
  * I40E_VFGEN_RSTAT on the VF
-- 
1.9.3

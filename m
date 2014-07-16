From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/5] i40e/i40evf: Clean up code
Date: Wed, 16 Jul 2014 14:35:33 -0700
Message-ID: <1405546534-21025-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1405546534-21025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28351 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746AbaGPVgN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 17:36:13 -0400
In-Reply-To: <1405546534-21025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>

1. Remove some break statements that will never get touched.
2. Remove an extra space.
3. Remove a comment for a parameter that doesn't exist
4. Move the assignment of a variable up to get rid of an else case.

Change-ID: I308a4b5ec070b1f0601f13b041ba4375aaad4b06
Signed-off-by: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c   | 1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 3 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c     | 1 -
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 2 +-
 5 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 2708bcd..0e551f2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -863,7 +863,7 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 			/* ugh! delay while spin_lock */
 			udelay(delay_len);
 			total_delay += delay_len;
-		} while (total_delay <  hw->aq.asq_cmd_timeout);
+		} while (total_delay < hw->aq.asq_cmd_timeout);
 	}
 
 	/* if ready, copy the desc back to temp */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 51087b5..c65f4e8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -554,7 +554,6 @@ i40e_status i40e_init_shared_code(struct i40e_hw *hw)
 		break;
 	default:
 		return I40E_ERR_DEVICE_NOT_SUPPORTED;
-		break;
 	}
 
 	hw->phy.get_link_info = true;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1f72eec..c34e390 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6773,13 +6773,12 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	 * maximum might end up larger than the available queues
 	 */
 	pf->rss_size_max = 0x1 << pf->hw.func_caps.rss_table_entry_width;
+	pf->rss_size = 1;
 	pf->rss_size_max = min_t(int, pf->rss_size_max,
 				 pf->hw.func_caps.num_tx_qp);
 	if (pf->hw.func_caps.rss) {
 		pf->flags |= I40E_FLAG_RSS_ENABLED;
 		pf->rss_size = min_t(int, pf->rss_size_max, num_online_cpus());
-	} else {
-		pf->rss_size = 1;
 	}
 
 	/* MFP mode enabled */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 79489a8..989866a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -303,7 +303,6 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
  * a specific flow spec
  * @vsi: pointer to the targeted VSI
  * @fd_data: the flow director data required for the FDir descriptor
- * @raw_packet: the pre-allocated packet buffer for FDir
  * @add: true adds a filter, false removes it
  *
  * Always returns -EOPNOTSUPP
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index cc4b6db..8330744b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -817,7 +817,7 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
 			/* ugh! delay while spin_lock */
 			udelay(delay_len);
 			total_delay += delay_len;
-		} while (total_delay <  hw->aq.asq_cmd_timeout);
+		} while (total_delay < hw->aq.asq_cmd_timeout);
 	}
 
 	/* if ready, copy the desc back to temp */
-- 
1.9.3

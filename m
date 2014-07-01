From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] i40e/i40evf: add ASQ write back timeout variable to AQ structure
Date: Tue,  1 Jul 2014 04:35:03 -0700
Message-ID: <1404214511-26868-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kamil Krawczyk <kamil.krawczyk@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7330 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756335AbaGALfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 07:35:16 -0400
In-Reply-To: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamil Krawczyk <kamil.krawczyk@intel.com>

Add new variable defining ASQ command write back timeout to allow for
dynamic modification of this timeout. Initialize it on AQ initialize
routine with default value, vary it on device ID.

Change-ID: I5c9908f9d7c5455634353b694a986d6f146d1b9d
Signed-off-by: Kamil Krawczyk <kamil.krawczyk@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   | 5 ++++-
 drivers/net/ethernet/intel/i40e/i40e_adminq.h   | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c | 5 ++++-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h | 1 +
 4 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index a8244a5..2708bcd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -571,6 +571,9 @@ i40e_status i40e_init_adminq(struct i40e_hw *hw)
 	/* Set up register offsets */
 	i40e_adminq_init_regs(hw);
 
+	/* setup ASQ command write back timeout */
+	hw->aq.asq_cmd_timeout = I40E_ASQ_CMD_TIMEOUT;
+
 	/* allocate the ASQ */
 	ret_code = i40e_init_asq(hw);
 	if (ret_code)
@@ -860,7 +863,7 @@ i40e_status i40e_asq_send_command(struct i40e_hw *hw,
 			/* ugh! delay while spin_lock */
 			udelay(delay_len);
 			total_delay += delay_len;
-		} while (total_delay <  I40E_ASQ_CMD_TIMEOUT);
+		} while (total_delay <  hw->aq.asq_cmd_timeout);
 	}
 
 	/* if ready, copy the desc back to temp */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
index c6142ba..bb76be1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
@@ -84,6 +84,7 @@ struct i40e_arq_event_info {
 struct i40e_adminq_info {
 	struct i40e_adminq_ring arq;    /* receive queue */
 	struct i40e_adminq_ring asq;    /* send queue */
+	u32 asq_cmd_timeout;            /* send queue cmd write back timeout*/
 	u16 num_arq_entries;            /* receive queue depth */
 	u16 num_asq_entries;            /* send queue depth */
 	u16 arq_buf_size;               /* receive queue buffer size */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index c277763..cc4b6db 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -567,6 +567,9 @@ i40e_status i40evf_init_adminq(struct i40e_hw *hw)
 	/* Set up register offsets */
 	i40e_adminq_init_regs(hw);
 
+	/* setup ASQ command write back timeout */
+	hw->aq.asq_cmd_timeout = I40E_ASQ_CMD_TIMEOUT;
+
 	/* allocate the ASQ */
 	ret_code = i40e_init_asq(hw);
 	if (ret_code)
@@ -814,7 +817,7 @@ i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
 			/* ugh! delay while spin_lock */
 			udelay(delay_len);
 			total_delay += delay_len;
-		} while (total_delay <  I40E_ASQ_CMD_TIMEOUT);
+		} while (total_delay <  hw->aq.asq_cmd_timeout);
 	}
 
 	/* if ready, copy the desc back to temp */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index 9335375..1628455 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -84,6 +84,7 @@ struct i40e_arq_event_info {
 struct i40e_adminq_info {
 	struct i40e_adminq_ring arq;    /* receive queue */
 	struct i40e_adminq_ring asq;    /* send queue */
+	u32 asq_cmd_timeout;            /* send queue cmd write back timeout*/
 	u16 num_arq_entries;            /* receive queue depth */
 	u16 num_asq_entries;            /* send queue depth */
 	u16 arq_buf_size;               /* receive queue buffer size */
-- 
1.9.3

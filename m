From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] i40e/i40evf: initialize context descriptor
Date: Tue,  1 Jul 2014 04:35:05 -0700
Message-ID: <1404214511-26868-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7355 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757807AbaGALfS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 07:35:18 -0400
In-Reply-To: <1404214511-26868-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Driver needs to initialize all members of context descriptor. Stale
data is possible otherwise.

Change-ID: Idc6b53af45583509da42d5ec0824cbaf78aee64f
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index babb7e6..051e213 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1991,6 +1991,7 @@ static void i40e_create_tx_ctx(struct i40e_ring *tx_ring,
 	/* cpu_to_le32 and assign to struct fields */
 	context_desc->tunneling_params = cpu_to_le32(cd_tunneling);
 	context_desc->l2tag2 = cpu_to_le16(cd_l2tag2);
+	context_desc->rsvd = cpu_to_le16(0);
 	context_desc->type_cmd_tso_mss = cpu_to_le64(cd_type_cmd_tso_mss);
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 48ebb6c..f2762f5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1336,6 +1336,7 @@ static void i40e_create_tx_ctx(struct i40e_ring *tx_ring,
 	/* cpu_to_le32 and assign to struct fields */
 	context_desc->tunneling_params = cpu_to_le32(cd_tunneling);
 	context_desc->l2tag2 = cpu_to_le16(cd_l2tag2);
+	context_desc->rsvd = cpu_to_le16(0);
 	context_desc->type_cmd_tso_mss = cpu_to_le64(cd_type_cmd_tso_mss);
 }
 
-- 
1.9.3

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/17] i40e: Move RSS table size for VSIs to the VSI struct
Date: Tue,  3 Mar 2015 01:44:19 -0800
Message-ID: <1425375864-25117-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425375864-25117-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:10578 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755933AbbCCJog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 04:44:36 -0500
In-Reply-To: <1425375864-25117-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Since all VSIs don't have the same RSS table size,
have one for each VSI instead of having a single define
for RSS table size

Change-ID: Ic2c7c66e4a389d4b6c8841a707510a9735041f02
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 2 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +++
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 27d1d92..e7ceae8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -471,6 +471,8 @@ struct i40e_vsi {
 	u16 rx_itr_setting;
 	u16 tx_itr_setting;
 
+	u16 rss_table_size;
+
 	u16 max_frame;
 	u16 rx_hdr_len;
 	u16 rx_buf_len;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index fae83ac..d6d8c30 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6713,6 +6713,8 @@ static int i40e_vsi_mem_alloc(struct i40e_pf *pf, enum i40e_vsi_type type)
 	vsi->idx = vsi_idx;
 	vsi->rx_itr_setting = pf->rx_itr_default;
 	vsi->tx_itr_setting = pf->tx_itr_default;
+	vsi->rss_table_size = (vsi->type == I40E_VSI_MAIN) ?
+				pf->rss_table_size : 64;
 	vsi->netdev_registered = false;
 	vsi->work_limit = I40E_DEFAULT_IRQ_WORK;
 	INIT_LIST_HEAD(&vsi->mac_filter_list);
@@ -7452,6 +7454,7 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	 */
 	pf->rss_size_max = 0x1 << pf->hw.func_caps.rss_table_entry_width;
 	pf->rss_size = 1;
+	pf->rss_table_size = pf->hw.func_caps.rss_table_size;
 	pf->rss_size_max = min_t(int, pf->rss_size_max,
 				 pf->hw.func_caps.num_tx_qp);
 	if (pf->hw.func_caps.rss) {
-- 
1.9.3

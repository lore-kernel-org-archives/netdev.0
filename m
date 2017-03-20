From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/13] i40e: explicitly fail on extended MAC field for ethtool_rx_flow_spec
Date: Mon, 20 Mar 2017 16:47:11 -0700
Message-ID: <20170320234712.84157-13-jeffrey.t.kirsher@intel.com>
References: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:49349 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932165AbdCTXrX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 19:47:23 -0400
In-Reply-To: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Although we will fail the filter later due to checking flow_type which
will have a bogus invalid type, it is possible future refactoring will
remove this hidden failure case. Avoid a possible issue in the future by
explicitly checking the flow type at the start.

Change-Id: Ia98eb26f7b93ccbe38c7141e8f203ef496fc6598
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index d16a5a6b24fc..905d66e87247 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2771,6 +2771,10 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 
 	fsp = (struct ethtool_rx_flow_spec *)&cmd->fs;
 
+	/* Extended MAC field is not supported */
+	if (fsp->flow_type & FLOW_MAC_EXT)
+		return -EINVAL;
+
 	if (fsp->location >= (pf->hw.func_caps.fd_filters_best_effort +
 			      pf->hw.func_caps.fd_filters_guaranteed)) {
 		return -EINVAL;
-- 
2.12.0

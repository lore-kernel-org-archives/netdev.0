From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] i40e: reset fd_tcp_rule count when restoring filters
Date: Mon, 20 Mar 2017 16:47:08 -0700
Message-ID: <20170320234712.84157-10-jeffrey.t.kirsher@intel.com>
References: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:59023 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755949AbdCTXrU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 19:47:20 -0400
In-Reply-To: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Since we're about to reprogram the filters, we need to ensure that the
fd_tcp_rule count is correctly reset to 0. Otherwise, we will keep
a stale count that does not accurately reflect the number of programmed
TCPv4 filters.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 221e1705c031..437b79eeb8b5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3283,6 +3283,9 @@ static void i40e_fdir_filter_restore(struct i40e_vsi *vsi)
 	if (!(pf->flags & I40E_FLAG_FD_SB_ENABLED))
 		return;
 
+	/* Reset FDir counters as we're replaying all existing filters */
+	pf->fd_tcp_rule = 0;
+
 	hlist_for_each_entry_safe(filter, node,
 				  &pf->fdir_filter_list, fdir_node) {
 		i40e_add_del_fdir(vsi, filter, true);
-- 
2.12.0

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/15] i40evf: remove leftover VLAN filters
Date: Tue, 13 Jan 2015 11:58:03 -0800
Message-ID: <1421179093-10932-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52238 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753648AbbAMT6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 14:58:17 -0500
In-Reply-To: <1421179093-10932-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

If we're using VLANs and communications with the PF fail during
shutdown, we will leak memory because not all of the VLAN filters will
be removed. To eliminate this possibility, go through the list again
right before the module is removed and delete any leftover entries.

Change-ID: Id3b5315c47ca0a61ae123a96ff345d010bc41aed
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index d339256..994ae4e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2462,6 +2462,10 @@ static void i40evf_remove(struct pci_dev *pdev)
 		list_del(&f->list);
 		kfree(f);
 	}
+	list_for_each_entry_safe(f, ftmp, &adapter->vlan_filter_list, list) {
+		list_del(&f->list);
+		kfree(f);
+	}
 
 	free_netdev(netdev);
 
-- 
1.9.3

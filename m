From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/20] i40evf: null out ring pointers on free
Date: Thu,  4 Feb 2016 03:48:57 -0800
Message-ID: <1454586551-35919-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50262 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965747AbcBDLtR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:17 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Since we check these ring pointers to make sure we don't double-allocate
or double-free the rings, we had better null them out after we free
them. In very rare cases this can cause a panic if the driver is removed
during reset recovery.

Change-ID: Ib06eb4910a3058275c8f7ec5ef7f45baa4674f96
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index d1c4335..81d9584 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1122,7 +1122,9 @@ static void i40evf_free_queues(struct i40evf_adapter *adapter)
 	if (!adapter->vsi_res)
 		return;
 	kfree(adapter->tx_rings);
+	adapter->tx_rings = NULL;
 	kfree(adapter->rx_rings);
+	adapter->rx_rings = NULL;
 }
 
 /**
-- 
2.5.0

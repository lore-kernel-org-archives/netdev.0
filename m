From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/4] i40e: remove client instance on driver unload
Date: Thu,  6 Apr 2017 20:23:23 -0700
Message-ID: <20170407032325.33374-3-jeffrey.t.kirsher@intel.com>
References: <20170407032325.33374-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:34860 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752013AbdDGDXa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:23:30 -0400
In-Reply-To: <20170407032325.33374-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When the driver is unloaded, we need to remove the client instance,
otherwise we leak memory.

Change-ID: If1e7882ac1f6ce15d004722fafbe31afbe0adc9a
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 191028b1489b..d05296a7078e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -459,6 +459,9 @@ int i40e_lan_del_device(struct i40e_pf *pf)
 	struct i40e_device *ldev, *tmp;
 	int ret = -ENODEV;
 
+	/* First, remove any client instance. */
+	i40e_client_del_instance(pf);
+
 	mutex_lock(&i40e_device_mutex);
 	list_for_each_entry_safe(ldev, tmp, &i40e_devices, list) {
 		if (ldev->pf == pf) {
-- 
2.12.2

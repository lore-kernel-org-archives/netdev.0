From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/4] i40e: register existing client on probe
Date: Thu,  6 Apr 2017 20:23:24 -0700
Message-ID: <20170407032325.33374-4-jeffrey.t.kirsher@intel.com>
References: <20170407032325.33374-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:43971 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752725AbdDGDXa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Apr 2017 23:23:30 -0400
In-Reply-To: <20170407032325.33374-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

In some cases, a client (i40iw) may already be present when probe is
called. Check for this, and add a client instance if necessary.

Change-ID: I2009312694b7ad81f1023919e4c6c86181f21689
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index d05296a7078e..eb2896fd52a6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -436,6 +436,12 @@ int i40e_lan_add_device(struct i40e_pf *pf)
 		 pf->hw.pf_id, pf->hw.bus.bus_id,
 		 pf->hw.bus.device, pf->hw.bus.func);
 
+	/* If a client has already been registered, we need to add an instance
+	 * of it to our new LAN device.
+	 */
+	if (registered_client)
+		i40e_client_add_instance(pf);
+
 	/* Since in some cases register may have happened before a device gets
 	 * added, we can schedule a subtask to go initiate the clients if
 	 * they can be launched at probe time.
-- 
2.12.2

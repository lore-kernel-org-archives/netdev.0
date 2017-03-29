From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/13] i40e: fix for queue timing delays
Date: Wed, 29 Mar 2017 03:12:15 -0700
Message-ID: <20170329101215.24513-14-jeffrey.t.kirsher@intel.com>
References: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3161 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755642AbdC2KMo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 06:12:44 -0400
In-Reply-To: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>

This patch adds a delay to Rx queue disables to accommodate HW needs.

v2: Added missing check for disable only, additional details on the
need for the ugly delay and fixed spacing on comment.

Change-ID: I2864ca667ce5dcc2cc44f8718113b719742a46a1
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1f89e416156d..a0506e28d167 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4067,6 +4067,12 @@ static int i40e_vsi_control_rx(struct i40e_vsi *vsi, bool enable)
 		}
 	}
 
+	/* Due to HW errata, on Rx disable only, the register can indicate done
+	 * before it really is. Needs 50ms to be sure
+	 */
+	if (!enable)
+		mdelay(50);
+
 	return ret;
 }
 
-- 
2.12.0

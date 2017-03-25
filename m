From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/11] i40e: fix for queue timing delays
Date: Sat, 25 Mar 2017 01:12:59 -0700
Message-ID: <20170325081305.31835-6-jeffrey.t.kirsher@intel.com>
References: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:32490 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751079AbdCYINK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 25 Mar 2017 04:13:10 -0400
In-Reply-To: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds a delay to Rx queue disables to accommodate HW needs.

Change-ID: I2864ca667ce5dcc2cc44f8718113b719742a46a1
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5da990909a88..1435033faefe 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4181,6 +4181,8 @@ static int i40e_vsi_control_rx(struct i40e_vsi *vsi, bool enable)
 		}
 	}
 
+	/* HW needs up to 50ms to finish RX queue disable*/
+	mdelay(50);
 	return ret;
 }
 
-- 
2.12.0

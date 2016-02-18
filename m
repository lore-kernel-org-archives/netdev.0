From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40evf: set adapter state on reset failure
Date: Thu, 18 Feb 2016 01:04:09 -0800
Message-ID: <1455786252-71881-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36842 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425727AbcBRJEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:04:36 -0500
In-Reply-To: <1455786252-71881-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If a reset fails to complete, the driver gets its affairs in order and
awaits the cold solace of rmmod. Unfortunately, it was not properly
setting the adapter state, which would cause a panic on rmmod, instead
of the desired surcease.

Set the adapter state to DOWN in this case, and avoid a panic.

Change-ID: I6fdd9906da52e023f8dc744f7da44b5d95278ca9
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 1176326..cbb7507 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1883,6 +1883,7 @@ static void i40evf_reset_task(struct work_struct *work)
 		adapter->netdev->flags &= ~IFF_UP;
 		clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
 		adapter->flags &= ~I40EVF_FLAG_RESET_PENDING;
+		adapter->state = __I40EVF_DOWN;
 		dev_info(&adapter->pdev->dev, "Reset task did not complete, VF disabled\n");
 		return; /* Do not attempt to reinit. It's dead, Jim. */
 	}
-- 
2.5.0

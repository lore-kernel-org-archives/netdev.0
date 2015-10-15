From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/17] i40evf: speed up init
Date: Thu, 15 Oct 2015 02:40:02 -0700
Message-ID: <1444902004-14433-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27563 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752483AbbJOJme (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:34 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Shorten up the delays in the init task, allowing the VF driver to
initialize faster. This aids performance in load/unload tests and
mitigates DMAR errors in VF enable/disable tests with absurdly short
delays. In the real world, the VF driver will come up more quickly.

The original values were set conservatively based on what we expected
from the firmware in terms of performance. Now that the driver is in use
and we know how well firmware responds to our requests, we can shorten
these delays.

Change-ID: Ibead77d34b19e8170e667c3f58bc14748bbc5bc9
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index f156226..bccca50 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2315,7 +2315,7 @@ static void i40evf_init_task(struct work_struct *work)
 	}
 	return;
 restart:
-	schedule_delayed_work(&adapter->init_task, msecs_to_jiffies(30));
+	schedule_delayed_work(&adapter->init_task, msecs_to_jiffies(20));
 	return;
 
 err_register:
@@ -2332,7 +2332,7 @@ err:
 		adapter->flags |= I40EVF_FLAG_PF_COMMS_FAILED;
 		return; /* do not reschedule */
 	}
-	schedule_delayed_work(&adapter->init_task, HZ * 3);
+	schedule_delayed_work(&adapter->init_task, HZ / 2);
 }
 
 /**
-- 
2.4.3

From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 12/15] i40evf: do not re-arm watchdog after remove
Date: Wed, 30 Jul 2014 17:32:08 -0700
Message-ID: <1406766731-4209-13-git-send-email-aaron.f.brown@intel.com>
References: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Cc: Ashish Shah <ashish.n.shah@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:24434 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756064AbaGaA2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 20:28:22 -0400
In-Reply-To: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ashish Shah <ashish.n.shah@intel.com>

Add in an adapter state check to prevent re-arming watchdog timer after
i40evf_remove has been called and timer has been deleted.

Change-ID: I636ba7c6322be8cbf053231959f90c0a2d8d803a
Signed-off-by: Ashish Shah <ashish.n.shah@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 4c01079..2aca9cf 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1403,6 +1403,8 @@ static void i40evf_watchdog_task(struct work_struct *work)
 watchdog_done:
 	clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
 restart_watchdog:
+	if (adapter->state == __I40EVF_REMOVE)
+		return;
 	if (adapter->aq_required)
 		mod_timer(&adapter->watchdog_timer,
 			  jiffies + msecs_to_jiffies(20));
-- 
1.9.3

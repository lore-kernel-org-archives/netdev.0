From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: Cleanup reconfig rss path
Date: Thu,  9 Jan 2014 04:52:16 -0800
Message-ID: <1389271944-26227-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44616 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755074AbaAIMwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 07:52:33 -0500
In-Reply-To: <1389271944-26227-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

RSS initialization was doing some extra work, remove the extra
work and any bugs it created when managing number of queues.

Change-ID: Iea75b04a70d73ce76947b6a177ce89ab4899d4c6
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index beb90e9..e782db9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5771,16 +5771,8 @@ int i40e_reconfig_rss_queues(struct i40e_pf *pf, int queue_count)
 	queue_count = rounddown_pow_of_two(queue_count);
 
 	if (queue_count != pf->rss_size) {
-		if (pf->queues_left < (queue_count - pf->rss_size)) {
-			dev_info(&pf->pdev->dev,
-				"Not enough queues to do RSS on %d queues: remaining queues %d\n",
-				queue_count, pf->queues_left);
-			return pf->rss_size;
-		}
 		i40e_prep_for_reset(pf);
 
-		pf->num_lan_qps += (queue_count - pf->rss_size);
-		pf->queues_left -= (queue_count - pf->rss_size);
 		pf->rss_size = queue_count;
 
 		i40e_reset_and_rebuild(pf, true);
-- 
1.8.3.1

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 03/15] i40evf: use min_t
Date: Wed, 19 Mar 2014 20:29:53 -0700
Message-ID: <1395286205-9676-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395286205-9676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20420 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753380AbaCTDaS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2014 23:30:18 -0400
In-Reply-To: <1395286205-9676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Checkpatch complained in an earlier patch about using min(), but that
change would have been completely unrelated to the point of that patch.
So fix it here.

Change-ID: I2cd87b39cfd406850d283b88f259757a6bcd14cd
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index ffda565..5575ee7 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1140,8 +1140,8 @@ static int i40evf_set_interrupt_capability(struct i40evf_adapter *adapter)
 	 * than CPU's.  So let's be conservative and only ask for
 	 * (roughly) twice the number of vectors as there are CPU's.
 	 */
-	v_budget = min(pairs, (int)(num_online_cpus() * 2)) + NONQ_VECS;
-	v_budget = min(v_budget, (int)adapter->vf_res->max_vectors);
+	v_budget = min_t(int, pairs, (int)(num_online_cpus() * 2)) + NONQ_VECS;
+	v_budget = min_t(int, v_budget, (int)adapter->vf_res->max_vectors);
 
 	/* A failure in MSI-X entry allocation isn't fatal, but it does
 	 * mean we disable MSI-X capabilities of the adapter.
-- 
1.8.3.1

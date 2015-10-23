From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/17] i40evf: use correct struct for list manipulation
Date: Fri, 23 Oct 2015 06:17:46 -0700
Message-ID: <1445606279-19345-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61352 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbbJWNST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 09:18:19 -0400
In-Reply-To: <1445606279-19345-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Not sure how this compiles at all. Use the correct struct for
manipulating the VLAN filter list. Without this, the VLAN filter
list doesn't get processed correctly, and VLAN filters will not
be re-enabled after any kind of reset.

Change-ID: Iceff2dc089f303058fb71ecb08419eed471e0e90
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 10b2a4a..0409383 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1609,6 +1609,7 @@ static void i40evf_reset_task(struct work_struct *work)
 						      reset_task);
 	struct net_device *netdev = adapter->netdev;
 	struct i40e_hw *hw = &adapter->hw;
+	struct i40evf_vlan_filter *vlf;
 	struct i40evf_mac_filter *f;
 	u32 reg_val;
 	int i = 0, err;
@@ -1732,8 +1733,8 @@ continue_reset:
 		f->add = true;
 	}
 	/* re-add all VLAN filters */
-	list_for_each_entry(f, &adapter->vlan_filter_list, list) {
-		f->add = true;
+	list_for_each_entry(vlf, &adapter->vlan_filter_list, list) {
+		vlf->add = true;
 	}
 	adapter->aq_required |= I40EVF_FLAG_AQ_ADD_MAC_FILTER;
 	adapter->aq_required |= I40EVF_FLAG_AQ_ADD_VLAN_FILTER;
-- 
2.4.3

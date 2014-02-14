From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 02/14] i40evf: remove VLAN filters on close
Date: Fri, 14 Feb 2014 14:57:56 -0800
Message-ID: <1392418688-23895-3-git-send-email-aaron.f.brown@intel.com>
References: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61878 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753162AbaBNXBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 18:01:20 -0500
In-Reply-To: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

We remove all the MAC filters, so remove the VLAN filters, too.

Change-ID: I4f7559acdf005dc3f359bf6460ce32d183c8878b
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 1629b73..75a2c6f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -972,9 +972,14 @@ void i40evf_down(struct i40evf_adapter *adapter)
 	list_for_each_entry(f, &adapter->mac_filter_list, list) {
 		f->remove = true;
 	}
+	/* remove all VLAN filters */
+	list_for_each_entry(f, &adapter->vlan_filter_list, list) {
+		f->remove = true;
+	}
 	if (!(adapter->flags & I40EVF_FLAG_PF_COMMS_FAILED) &&
 	    adapter->state != __I40EVF_RESETTING) {
 		adapter->aq_required |= I40EVF_FLAG_AQ_DEL_MAC_FILTER;
+		adapter->aq_required |= I40EVF_FLAG_AQ_DEL_VLAN_FILTER;
 		/* disable receives */
 		adapter->aq_required |= I40EVF_FLAG_AQ_DISABLE_QUEUES;
 		mod_timer_pending(&adapter->watchdog_timer, jiffies + 1);
-- 
1.8.5.GIT

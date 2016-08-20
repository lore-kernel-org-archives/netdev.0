From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40evf: Open RDMA Client after reset
Date: Fri, 19 Aug 2016 23:19:51 -0700
Message-ID: <1471673991-117115-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Avinash Dayanand <avinash.dayanand@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:41155 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752102AbcHTGax (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 02:30:53 -0400
In-Reply-To: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Avinash Dayanand <avinash.dayanand@intel.com>

RDMA client is closed during the PF reset and needs to be opened again.
Setting the flag so that RDMA client is opened in watchdog() function.

Change-ID: I507b1e4cbd05528cdff68fd360ef3dcac8901263
Signed-off-by: Avinash Dayanand <avinash.dayanand@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 24f88ec..f751f7b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1804,6 +1804,8 @@ continue_reset:
 	}
 	adapter->aq_required |= I40EVF_FLAG_AQ_ADD_MAC_FILTER;
 	adapter->aq_required |= I40EVF_FLAG_AQ_ADD_VLAN_FILTER;
+	/* Open RDMA Client again */
+	adapter->aq_required |= I40EVF_FLAG_SERVICE_CLIENT_REQUESTED;
 	clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
 	i40evf_misc_irq_enable(adapter);
 
-- 
2.7.4

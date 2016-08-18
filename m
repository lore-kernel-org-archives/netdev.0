From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40evf: add missing rtnl_lock() around i40evf_set_interrupt_capability
Date: Thu, 18 Aug 2016 14:57:26 -0700
Message-ID: <1471557456-136741-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11107 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754417AbcHSA6T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 20:58:19 -0400
In-Reply-To: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The function calls netif_set_real_num_(tx|rx)_queues, both of which
should be done only under rntl lock. Unfortunately the
i40evf_init_task did not hold the rtnl_lock as necessary. This patch
adds the locking needed.

Change-ID: Ib72a21c3ce22b71a226b16f9bbe0f5f8cc3e849b
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 600fb9c..d1d4a65 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1420,7 +1420,9 @@ int i40evf_init_interrupt_scheme(struct i40evf_adapter *adapter)
 {
 	int err;
 
+	rtnl_lock();
 	err = i40evf_set_interrupt_capability(adapter);
+	rtnl_unlock();
 	if (err) {
 		dev_err(&adapter->pdev->dev,
 			"Unable to setup interrupt capabilities\n");
-- 
2.7.4

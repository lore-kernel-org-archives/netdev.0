From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/16] i40evf: don't shut down admin queue on error
Date: Fri, 21 Mar 2014 05:09:53 -0700
Message-ID: <1395403806-29302-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15182 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965462AbaCUMKL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:11 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the driver encounters an error while communicating with the PF
driver,  don't just shut down the admin queue unconditionally. The PF
may be delayed, and shutting down the admin queue causes it to fail
completely. If this happens, the VF will never complete initialization.

Change-ID: I6192e9d8caeefb738428c3597fa2f54fa400ce7f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index d381bcc..4d547ab 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2133,8 +2133,6 @@ err_alloc:
 	kfree(adapter->vf_res);
 	adapter->vf_res = NULL;
 err:
-	if (hw->aq.asq.count)
-		i40evf_shutdown_adminq(hw); /* ignore error */
 	/* Things went into the weeds, so try again later */
 	if (++adapter->aq_wait_count > I40EVF_AQ_MAX_ERR) {
 		dev_err(&pdev->dev, "Failed to communicate with PF; giving up.\n");
-- 
1.8.3.1

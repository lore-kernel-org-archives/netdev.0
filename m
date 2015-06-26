From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 10/10] i40evf: don't configure unused RSS queues
Date: Fri, 26 Jun 2015 03:20:40 -0700
Message-ID: <1435314040-3228-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59229 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751863AbbFZKVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 06:21:01 -0400
In-Reply-To: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The driver will only configure as many queues as there are available
CPUs, up the maximum number of queues. However, it always configures
RSS as though it is using the maximum number of queues. This can cause
the device to drop a lot of RX traffic, as the packets get assigned to
nonfunctional queues.

Fix this by only configuring RSS with the number of active queues.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 5c73374..4ab4ebb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1461,7 +1461,7 @@ static void i40evf_configure_rss(struct i40evf_adapter *adapter)
 	for (i = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++) {
 		lut = 0;
 		for (j = 0; j < 4; j++) {
-			if (cqueue == adapter->vsi_res->num_queue_pairs)
+			if (cqueue == adapter->num_active_queues)
 				cqueue = 0;
 			lut |= ((cqueue) << (8 * j));
 			cqueue++;
-- 
2.4.3

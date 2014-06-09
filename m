From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] i40e: Do not fall back to one queue model if the only feature enabled is ATR
Date: Mon,  9 Jun 2014 01:49:15 -0700
Message-ID: <1402303758-1429-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27483 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754651AbaFIIta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 04:49:30 -0400
In-Reply-To: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

FD_SB and FD_ATR needs to be checked independently in order to decide if
we will support multiple queues or not.

Change-ID: I9d3274f5924c79e29efdbcf66a2fcca1fee2107f
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b5f0dea..2f11542 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8194,6 +8194,7 @@ static void i40e_determine_queue_usage(struct i40e_pf *pf)
 			       I40E_FLAG_VMDQ_ENABLED);
 	} else if (!(pf->flags & (I40E_FLAG_RSS_ENABLED |
 				  I40E_FLAG_FD_SB_ENABLED |
+				  I40E_FLAG_FD_ATR_ENABLED |
 				  I40E_FLAG_DCB_ENABLED))) {
 		/* one qp for PF */
 		pf->rss_size = pf->num_lan_qps = 1;
-- 
1.9.3

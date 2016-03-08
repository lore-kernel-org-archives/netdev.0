From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/4] cxgb4vf: Add a couple more checks for invalid provisioning configurations
Date: Tue,  8 Mar 2016 10:50:19 +0530
Message-ID: <1457414420-5237-4-git-send-email-hariprasad@chelsio.com>
References: <1457414420-5237-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:5881 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753963AbcCHFWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 00:22:19 -0500
In-Reply-To: <1457414420-5237-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 17a3153..5a3b883 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2361,6 +2361,11 @@ static int adap_init0(struct adapter *adapter)
 	}
 
 	/* Check for various parameter sanity issues */
+	if (adapter->params.vfres.pmask == 0) {
+		dev_err(adapter->pdev_dev, "no port access configured\n"
+			"usable!\n");
+		return -EINVAL;
+	}
 	if (adapter->params.vfres.nvi == 0) {
 		dev_err(adapter->pdev_dev, "no virtual interfaces configured/"
 			"usable!\n");
-- 
1.7.3

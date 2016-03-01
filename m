From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/5] cxgb4vf: Remove redundant adapter ready check during probe
Date: Tue,  1 Mar 2016 17:19:35 +0530
Message-ID: <1456832976-12840-5-git-send-email-hariprasad@chelsio.com>
References: <1456832976-12840-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, nirranjan@chelsio.com, leedom@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:54382 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753372AbcCALq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 06:46:56 -0500
In-Reply-To: <1456832976-12840-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function t4vf_wait_dev_ready() is already called in t4vf_prep_adapter(),
no need to call it again in adap_init0().

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 8337514ababb..5d989e4c42dc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2237,16 +2237,6 @@ static int adap_init0(struct adapter *adapter)
 	u32 param, val = 0;
 
 	/*
-	 * Wait for the device to become ready before proceeding ...
-	 */
-	err = t4vf_wait_dev_ready(adapter);
-	if (err) {
-		dev_err(adapter->pdev_dev, "device didn't become ready:"
-			" err=%d\n", err);
-		return err;
-	}
-
-	/*
 	 * Some environments do not properly handle PCIE FLRs -- e.g. in Linux
 	 * 2.6.31 and later we can't call pci_reset_function() in order to
 	 * issue an FLR because of a self- deadlock on the device semaphore.
-- 
2.3.4

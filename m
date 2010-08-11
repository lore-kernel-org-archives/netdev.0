From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/8] qlcnic: fix for setting function modes
Date: Wed, 11 Aug 2010 05:05:24 -0700
Message-ID: <1281528329-8812-4-git-send-email-amit.salecha@qlogic.com>
References: <1281528329-8812-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:53899 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751572Ab0HKMFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 08:05:30 -0400
In-Reply-To: <1281528329-8812-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

function modes was not working with CNA device, in CNA mode
other function(FCOE) can be enabled before nic.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index bac2371..49c8110 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -533,8 +533,6 @@ qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 	ret = qlcnic_api_lock(adapter);
 	if (ret)
 		goto err_lock;
-	if (QLC_DEV_CLR_REF_CNT(ref_count, adapter->ahw.pci_func))
-		goto err_npar;
 
 	if (qlcnic_config_npars) {
 		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
@@ -552,7 +550,6 @@ qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 			adapter->ahw.pci_func));
 	}
 	writel(data, priv_op);
-err_npar:
 	qlcnic_api_unlock(adapter);
 err_lock:
 	return ret;
-- 
1.6.0.2


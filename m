From: leitao@linux.vnet.ibm.com
Subject: [PATCH] cxgb3: Fixing EEH handlers
Date: Thu, 10 Dec 2009 13:03:37 -0600
Message-ID: <1260471817-7184-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:48486 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761312AbZLJTHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 14:07:55 -0500
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp04.br.ibm.com (8.14.3/8.13.1) with ESMTP id nBAIwtPM030224
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 16:58:55 -0200
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBAJ9aHe774604
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 17:09:37 -0200
Received: from d24av03.br.ibm.com (loopback [127.0.0.1])
	by d24av03.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBAJ80cR030579
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 17:08:00 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff, the EEH
is not working proplery on cxgb3.

This patch fixes it, always saving the PCI state after a recovery,
in order to allow further reoveries.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/cxgb3/cxgb3_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index cef3f88..89bec9c 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2860,6 +2860,7 @@ static int t3_reenable_adapter(struct adapter *adapter)
 	}
 	pci_set_master(adapter->pdev);
 	pci_restore_state(adapter->pdev);
+	pci_save_state(adapter->pdev);
 
 	/* Free sge resources */
 	t3_free_sge_resources(adapter);
-- 
1.6.0.2


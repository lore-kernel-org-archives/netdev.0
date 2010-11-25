From: leitao@linux.vnet.ibm.com
Subject: [PATCH] cxgb3: Removing unused return variable
Date: Thu, 25 Nov 2010 15:53:55 -0200
Message-ID: <1290707635-31979-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:54126 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266Ab0KYRyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 12:54:08 -0500
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id oAPI8FwE009541
	for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 16:08:15 -0200
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAPI0wpg1208332
	for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 16:00:58 -0200
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAPHrk6o010088
	for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 15:53:47 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the ret variable is not used for anything other than
receive the value of the t3_adapter_error(), which will always be 0,
because the reset parameter is 0.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/cxgb3/cxgb3_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 046d846..3864617 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -3006,12 +3006,11 @@ static pci_ers_result_t t3_io_error_detected(struct pci_dev *pdev,
 					     pci_channel_state_t state)
 {
 	struct adapter *adapter = pci_get_drvdata(pdev);
-	int ret;
 
 	if (state == pci_channel_io_perm_failure)
 		return PCI_ERS_RESULT_DISCONNECT;
 
-	ret = t3_adapter_error(adapter, 0, 0);
+	t3_adapter_error(adapter, 0, 0);
 
 	/* Request a slot reset. */
 	return PCI_ERS_RESULT_NEED_RESET;
-- 
1.7.1


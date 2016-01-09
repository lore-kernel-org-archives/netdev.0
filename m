From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 01/10] qlcnic: protect qlcnic_82xx_io_slot_reset with rtnl lock
Date: Sat,  9 Jan 2016 16:07:23 +0100
Message-ID: <1452352052-27574-2-git-send-email-hannes@stressinduktion.org>
References: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org, Dept-GELinuxNICDev@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:41132 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754033AbcAIPHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 10:07:41 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 4568E209D8
	for <netdev@vger.kernel.org>; Sat,  9 Jan 2016 10:07:41 -0500 (EST)
In-Reply-To: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Dept-GELinuxNICDev@qlogic.com
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1205f6f9c94173..1c29105b6c364f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3952,8 +3952,14 @@ static pci_ers_result_t qlcnic_82xx_io_error_detected(struct pci_dev *pdev,
 
 static pci_ers_result_t qlcnic_82xx_io_slot_reset(struct pci_dev *pdev)
 {
-	return qlcnic_attach_func(pdev) ? PCI_ERS_RESULT_DISCONNECT :
-				PCI_ERS_RESULT_RECOVERED;
+	pci_ers_result_t res;
+
+	rtnl_lock();
+	res = qlcnic_attach_func(pdev) ? PCI_ERS_RESULT_DISCONNECT :
+					 PCI_ERS_RESULT_RECOVERED;
+	rtnl_unlock();
+
+	return res;
 }
 
 static void qlcnic_82xx_io_resume(struct pci_dev *pdev)
-- 
2.5.0

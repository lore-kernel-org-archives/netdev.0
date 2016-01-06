From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v3 1/8] qlcnic: protect qlcnic_82xx_io_slot_reset with rtnl lock
Date: Thu,  7 Jan 2016 00:39:24 +0100
Message-ID: <1452123571-19140-2-git-send-email-hannes@stressinduktion.org>
References: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org, Dept-GELinuxNICDev@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:36990 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752240AbcAFXjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 18:39:41 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 3D056203C9
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 18:39:41 -0500 (EST)
In-Reply-To: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
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

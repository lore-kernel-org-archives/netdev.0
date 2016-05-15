From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 5/5] qed: VFs gracefully accept lack of PM
Date: Sun, 15 May 2016 14:48:09 +0300
Message-ID: <1463312889-19351-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1463312889-19351-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:53085 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754143AbcEOLs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 07:48:29 -0400
In-Reply-To: <1463312889-19351-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VF's probe might log that it has no PM capability in its PCI configuration
space. As this is a valid configuration, silence such prints.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 6ffc21d..56f6bc1 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -158,7 +158,7 @@ static int qed_init_pci(struct qed_dev *cdev,
 	}
 
 	cdev->pci_params.pm_cap = pci_find_capability(pdev, PCI_CAP_ID_PM);
-	if (cdev->pci_params.pm_cap == 0)
+	if (IS_PF(cdev) && !cdev->pci_params.pm_cap)
 		DP_NOTICE(cdev, "Cannot find power management capability\n");
 
 	rc = qed_set_coherency_mask(cdev);
-- 
1.9.3

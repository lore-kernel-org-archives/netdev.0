From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 2/5] qed: Fix VF removal sequence
Date: Tue, 9 May 2017 15:07:48 +0300
Message-ID: <1494331671-16273-3-git-send-email-Yuval.Mintz@cavium.com>
References: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0046.outbound.protection.outlook.com ([104.47.33.46]:40864
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753210AbdEIMIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 08:08:16 -0400
In-Reply-To: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After previos changes in HW-stop scheme, VFs stopped sending CLOSE
messages to their PFs when they unload.

Fixes: 1226337ad98f ("qed: Correct HW stop flow")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index b7ad36b..0cbbd59 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1093,10 +1093,12 @@ static int qed_slowpath_stop(struct qed_dev *cdev)
 		qed_free_stream_mem(cdev);
 		if (IS_QED_ETH_IF(cdev))
 			qed_sriov_disable(cdev, true);
+	}
+
+	qed_nic_stop(cdev);
 
-		qed_nic_stop(cdev);
+	if (IS_PF(cdev))
 		qed_slowpath_irq_free(cdev);
-	}
 
 	qed_disable_msix(cdev);
 
-- 
1.9.3

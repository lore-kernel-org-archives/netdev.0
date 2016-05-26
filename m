From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 6/8] qed: Add missing 100g init mode
Date: Thu, 26 May 2016 11:01:22 +0300
Message-ID: <1464249684-976-7-git-send-email-Yuval.Mintz@qlogic.com>
References: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:60337 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753322AbcEZIBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 04:01:50 -0400
In-Reply-To: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the HW configurations are currently missing for 100g devices.
This can cause various classification issues, as well as prevent device
from fully reaching line-rate.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 920eadd..2a7c875 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -588,7 +588,14 @@ static void qed_calc_hw_mode(struct qed_hwfn *p_hwfn)
 
 	hw_mode |= 1 << MODE_ASIC;
 
+	if (p_hwfn->cdev->num_hwfns > 1)
+		hw_mode |= 1 << MODE_100G;
+
 	p_hwfn->hw_info.hw_mode = hw_mode;
+
+	DP_VERBOSE(p_hwfn, (NETIF_MSG_PROBE | NETIF_MSG_IFUP),
+		   "Configuring function for hw_mode: 0x%08x\n",
+		   p_hwfn->hw_info.hw_mode);
 }
 
 /* Init run time data for all PFs on an engine. */
-- 
1.9.3

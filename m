From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 8/8] qed: Don't config min BW on 100g on link flap
Date: Thu, 26 May 2016 11:01:24 +0300
Message-ID: <1464249684-976-9-git-send-email-Yuval.Mintz@qlogic.com>
References: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:60339 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753252AbcEZIBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 04:01:54 -0400
In-Reply-To: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently 100g devices don't support minimum/maximum BW configurations,
yet link flaps might cause the driver to attempt to do such a
configuration. Prevent this just as we do for the maximum BW.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_dev.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index 579c6d5..2d89e8c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -2105,6 +2105,13 @@ void qed_configure_vp_wfq_on_link_change(struct qed_dev *cdev, u32 min_pf_rate)
 {
 	int i;
 
+	if (cdev->num_hwfns > 1) {
+		DP_VERBOSE(cdev,
+			   NETIF_MSG_LINK,
+			   "WFQ configuration is not supported for this device\n");
+		return;
+	}
+
 	for_each_hwfn(cdev, i) {
 		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
 
-- 
1.9.3

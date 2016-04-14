From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH v2 net-next 4/5] qed: Enable GRE tunnel slowpath configuration
Date: Thu, 14 Apr 2016 01:38:32 -0400
Message-ID: <1460612313-20323-5-git-send-email-manish.chopra@qlogic.com>
References: <1460612313-20323-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39299 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751793AbcDNGUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 02:20:12 -0400
In-Reply-To: <1460612313-20323-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index c1533a6..1e9f321 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -779,10 +779,14 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 
 	memset(&tunn_info, 0, sizeof(tunn_info));
 	tunn_info.tunn_mode |=  1 << QED_MODE_VXLAN_TUNN |
+				1 << QED_MODE_L2GRE_TUNN |
+				1 << QED_MODE_IPGRE_TUNN |
 				1 << QED_MODE_L2GENEVE_TUNN |
 				1 << QED_MODE_IPGENEVE_TUNN;
 
 	tunn_info.tunn_clss_vxlan = QED_TUNN_CLSS_MAC_VLAN;
+	tunn_info.tunn_clss_l2gre = QED_TUNN_CLSS_MAC_VLAN;
+	tunn_info.tunn_clss_ipgre = QED_TUNN_CLSS_MAC_VLAN;
 
 	rc = qed_hw_init(cdev, &tunn_info, true,
 			 cdev->int_params.out.int_mode,
-- 
2.7.2

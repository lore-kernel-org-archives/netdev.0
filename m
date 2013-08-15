From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 3/3] qlcnic: Fix diagnostic interrupt test for 83xx adapters
Date: Thu, 15 Aug 2013 08:29:29 -0400
Message-ID: <1376569769-625-4-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1376569769-625-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:52642 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756298Ab3HONeM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 09:34:12 -0400
In-Reply-To: <1376569769-625-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Do not allow interrupt test when adapter is resetting.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 92da998..9d4bb7f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -3266,6 +3266,11 @@ int qlcnic_83xx_interrupt_test(struct net_device *netdev)
 	u8 val;
 	int ret, max_sds_rings = adapter->max_sds_rings;
 
+	if (test_bit(__QLCNIC_RESETTING, &adapter->state)) {
+		netdev_info(netdev, "Device is resetting\n");
+		return -EBUSY;
+	}
+
 	if (qlcnic_get_diag_lock(adapter)) {
 		netdev_info(netdev, "Device in diagnostics mode\n");
 		return -EBUSY;
-- 
1.8.1.4

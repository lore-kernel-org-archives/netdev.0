From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net 4/4] qlcnic: Fix diagnostic interrupt test for 83xx adapters.
Date: Fri, 26 Jul 2013 16:24:03 -0400
Message-ID: <03ef8c5f55cd7afa0a3c85ba670671aa86301087.1374891091.git.himanshu.madhani@qlogic.com>
References: <cover.1374891091.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53104 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932765Ab3GZV0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:26:08 -0400
In-Reply-To: <cover.1374891091.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Initialize proper interrupt handler for 83xx.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 41635f2..cc78d39 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1383,6 +1383,8 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	if (adapter->ahw->diag_test == QLCNIC_INTERRUPT_TEST) {
 		if (qlcnic_82xx_check(adapter))
 			handler = qlcnic_tmp_intr;
+		else
+			handler = qlcnic_83xx_tmp_intr;
 		if (!QLCNIC_IS_MSI_FAMILY(adapter))
 			flags |= IRQF_SHARED;
 
-- 
1.8.1.4

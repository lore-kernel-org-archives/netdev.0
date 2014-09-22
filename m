From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 1/4] qlcnic: Use qlcnic_83xx_flash_read32() API instead of lockless version of the API.
Date: Mon, 22 Sep 2014 05:51:50 -0400
Message-ID: <1411379513-26902-2-git-send-email-manish.chopra@qlogic.com>
References: <1411379513-26902-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:57823 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753906AbaIVKZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 06:25:49 -0400
In-Reply-To: <1411379513-26902-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

In qlcnic_83xx_setup_idc_parameters() routine use qlcnic_83xx_flash_read32() API
which takes flash lock internally instead of the lockless version
qlcnic_83xx_lockless_flash_read32().

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 86783e1..3172cdf 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1177,9 +1177,8 @@ static void qlcnic_83xx_setup_idc_parameters(struct qlcnic_adapter *adapter)
 {
 	u32 idc_params, val;
 
-	if (qlcnic_83xx_lockless_flash_read32(adapter,
-					      QLC_83XX_IDC_FLASH_PARAM_ADDR,
-					      (u8 *)&idc_params, 1)) {
+	if (qlcnic_83xx_flash_read32(adapter, QLC_83XX_IDC_FLASH_PARAM_ADDR,
+				     (u8 *)&idc_params, 1)) {
 		dev_info(&adapter->pdev->dev,
 			 "%s:failed to get IDC params from flash\n", __func__);
 		adapter->dev_init_timeo = QLC_83XX_IDC_INIT_TIMEOUT_SECS;
-- 
1.7.1

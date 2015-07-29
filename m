From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 1/1] qlcnic: Fix corruption while copying
Date: Wed, 29 Jul 2015 07:55:35 -0400
Message-ID: <1438170935-9302-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49872 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750871AbbG2MlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 08:41:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Use proper typecasting while performing byte-by-byte copy

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
Hi Dave,

Please apply this patch to net.

Thanks,
Shahed
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 78acec4..bf89216 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1415,7 +1415,7 @@ static int qlcnic_83xx_copy_fw_file(struct qlcnic_adapter *adapter)
 	if (fw->size & 0xF) {
 		addr = dest + size;
 		for (i = 0; i < (fw->size & 0xF); i++)
-			data[i] = temp[size + i];
+			data[i] = ((u8 *)temp)[size + i];
 		for (; i < 16; i++)
 			data[i] = 0;
 		ret = qlcnic_ms_mem_write128(adapter, addr,
-- 
1.5.6

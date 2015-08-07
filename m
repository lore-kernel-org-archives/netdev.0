From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 5/6] qlcnic: Don't use kzalloc unncecessarily for allocating large chunk of memory
Date: Fri, 7 Aug 2015 07:17:06 -0400
Message-ID: <1438946227-11426-6-git-send-email-shahed.shaikh@qlogic.com>
References: <1438946227-11426-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:36447 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753016AbbHGMC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 08:02:58 -0400
In-Reply-To: <1438946227-11426-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Driver allocates a large chunk of temporary buffer using kzalloc
to copy FW image. As there is no real need of this memory to be
physically contiguous, use vzalloc instead.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 753ea8b..bf89216 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -1384,7 +1384,7 @@ static int qlcnic_83xx_copy_fw_file(struct qlcnic_adapter *adapter)
 	size_t size;
 	u64 addr;
 
-	temp = kzalloc(fw->size, GFP_KERNEL);
+	temp = vzalloc(fw->size);
 	if (!temp) {
 		release_firmware(fw);
 		fw_info->fw = NULL;
@@ -1430,7 +1430,7 @@ static int qlcnic_83xx_copy_fw_file(struct qlcnic_adapter *adapter)
 exit:
 	release_firmware(fw);
 	fw_info->fw = NULL;
-	kfree(temp);
+	vfree(temp);
 
 	return ret;
 }
-- 
1.5.6

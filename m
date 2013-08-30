From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 3/9] qlcnic: Use firmware recommended dump capture mask as default
Date: Fri, 30 Aug 2013 13:51:18 -0400
Message-ID: <1377885084-6441-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:37814 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756827Ab3H3SUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 14:20:24 -0400
In-Reply-To: <1377885084-6441-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    1 -
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |    5 ++++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index f6aea7d..6c360d7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1403,7 +1403,6 @@ struct qlcnic_esw_statistics {
 	struct __qlcnic_esw_statistics tx;
 };
 
-#define QLCNIC_DUMP_MASK_DEF		0x1f
 #define QLCNIC_FORCE_FW_DUMP_KEY	0xdeadfeed
 #define QLCNIC_ENABLE_FW_DUMP		0xaddfeed
 #define QLCNIC_DISABLE_FW_DUMP		0xbadfeed
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index 79e54ef..b7871fe 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -1082,7 +1082,10 @@ flash_temp:
 	}
 
 	tmpl_hdr = ahw->fw_dump.tmpl_hdr;
-	tmpl_hdr->drv_cap_mask = QLCNIC_DUMP_MASK_DEF;
+	tmpl_hdr->drv_cap_mask = tmpl_hdr->cap_mask;
+	dev_info(&adapter->pdev->dev,
+		 "Default minidump capture mask 0x%x\n",
+		 tmpl_hdr->cap_mask);
 
 	if ((tmpl_hdr->version & 0xfffff) >= 0x20001)
 		ahw->fw_dump.use_pex_dma = true;
-- 
1.5.6

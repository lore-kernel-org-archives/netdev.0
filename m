From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 6/6] qlcnic: change capture mask for FW dump
Date: Thu, 14 Jul 2011 06:16:55 -0700
Message-ID: <1310649415-14787-7-git-send-email-amit.salecha@qlogic.com>
References: <1310649415-14787-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:44913 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754966Ab1GNNZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 09:25:49 -0400
In-Reply-To: <1310649415-14787-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

o Change FW dump capture mask to a defult value, instead of using the recommended
  value from the FW. This was done to keep the capture mask consistent with other
  function drivers.

o Update driver version to 5.0.21

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h     |    6 +++---
 drivers/net/qlcnic/qlcnic_ctx.c |    6 +-----
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index f6e54a8..baf646d 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -36,8 +36,8 @@
 
 #define _QLCNIC_LINUX_MAJOR 5
 #define _QLCNIC_LINUX_MINOR 0
-#define _QLCNIC_LINUX_SUBVERSION 20
-#define QLCNIC_LINUX_VERSIONID  "5.0.20"
+#define _QLCNIC_LINUX_SUBVERSION 21
+#define QLCNIC_LINUX_VERSIONID  "5.0.21"
 #define QLCNIC_DRV_IDC_VER  0x01
 #define QLCNIC_DRIVER_VERSION  ((_QLCNIC_LINUX_MAJOR << 16) |\
 		 (_QLCNIC_LINUX_MINOR << 8) | (_QLCNIC_LINUX_SUBVERSION))
@@ -1339,7 +1339,7 @@ enum op_codes {
 #define QLCNIC_DUMP_SKIP	BIT_7
 
 #define QLCNIC_DUMP_MASK_MIN		3
-#define QLCNIC_DUMP_MASK_DEF		0x7f
+#define QLCNIC_DUMP_MASK_DEF		0x1f
 #define QLCNIC_DUMP_MASK_MAX		0xff
 #define QLCNIC_FORCE_FW_DUMP_KEY	0xdeadfeed
 #define QLCNIC_ENABLE_FW_DUMP		0xaddfeed
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 33f5c8a..b0d32dd 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -145,11 +145,7 @@ int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter)
 		*template++ = __le32_to_cpu(*tmp_buf++);
 
 	tmpl_hdr = ahw->fw_dump.tmpl_hdr;
-	if (tmpl_hdr->cap_mask > QLCNIC_DUMP_MASK_DEF &&
-		tmpl_hdr->cap_mask <= QLCNIC_DUMP_MASK_MAX)
-		tmpl_hdr->drv_cap_mask = tmpl_hdr->cap_mask;
-	else
-		tmpl_hdr->drv_cap_mask = QLCNIC_DUMP_MASK_DEF;
+	tmpl_hdr->drv_cap_mask = QLCNIC_DUMP_MASK_DEF;
 	ahw->fw_dump.enable = 1;
 error:
 	dma_free_coherent(&adapter->pdev->dev, temp_size, tmp_addr, tmp_addr_t);
-- 
1.7.3.3


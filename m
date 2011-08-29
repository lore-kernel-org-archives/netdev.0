From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 3/5] qlcnic: Add FLT entry for CO cards FW image region
Date: Mon, 29 Aug 2011 15:50:28 -0700
Message-ID: <1314658231-30735-3-git-send-email-sony.chacko@qlogic.com>
References: <1314658231-30735-1-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:20779
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754103Ab1H2XDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 19:03:32 -0400
In-Reply-To: <1314658231-30735-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

The FLT entry for FW image region has changed for C0 cards.
Updated the driver to look at the right region in the FLT.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    4 +++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c |    8 +++++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 53c6e5d..4118502 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -73,6 +73,7 @@
 	(sizeof(struct cmd_desc_type0) * tx_ring->num_desc)
 
 #define QLCNIC_P3P_A0		0x50
+#define QLCNIC_P3P_C0		0x58
 
 #define QLCNIC_IS_REVISION_P3P(REVISION)     (REVISION >= QLCNIC_P3P_A0)
 
@@ -291,7 +292,8 @@ struct uni_data_desc{
 
 /* Flash Defines and Structures */
 #define QLCNIC_FLT_LOCATION	0x3F1000
-#define QLCNIC_FW_IMAGE_REGION	0x74
+#define QLCNIC_B0_FW_IMAGE_REGION 0x74
+#define QLCNIC_C0_FW_IMAGE_REGION 0x97
 #define QLCNIC_BOOTLD_REGION    0X72
 struct qlcnic_flt_header {
 	u16 version;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index b02859c..7f4b8e6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -686,7 +686,13 @@ qlcnic_check_flash_fw_ver(struct qlcnic_adapter *adapter)
 	u32 ver = -1, min_ver;
 	int ret;
 
-	ret = qlcnic_get_flt_entry(adapter, QLCNIC_FW_IMAGE_REGION, &fw_entry);
+	if (adapter->ahw->revision_id == QLCNIC_P3P_C0)
+		ret = qlcnic_get_flt_entry(adapter, QLCNIC_C0_FW_IMAGE_REGION,
+						 &fw_entry);
+	else
+		ret = qlcnic_get_flt_entry(adapter, QLCNIC_B0_FW_IMAGE_REGION,
+						 &fw_entry);
+
 	if (!ret)
 		/* 0-4:-signature,  4-8:-fw version */
 		qlcnic_rom_fast_read(adapter, fw_entry.start_addr + 4,
-- 
1.6.0.2

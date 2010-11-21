From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/62] benet: Use static const
Date: Sat, 20 Nov 2010 18:38:07 -0800
Message-ID: <b892daa5deeee1b21e4eb218b40ef3b692e8448d.1290305775.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sathya Perla <sathyap@serverengines.com>,
	Subbu Seetharaman <subbus@serverengines.com>,
	Sarveshwar Bandi <sarveshwarb@serverengines.com>,
	Ajit Khaparde <ajitk@serverengines.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
   9920	     56	   1248	  11224	   2bd8	drivers/net/benet/be_ethtool.o.old
   9839	     56	   1232	  11127	   2b77	drivers/net/benet/be_ethtool.o.new
  38586	    386	   8624	  47596	   b9ec	drivers/net/benet/be_main.o.old
  38452	    386	   8624	  47462	   b966	drivers/net/benet/be_main.o.new

Use ARRAY_SIZE not magic numbers.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/benet/be_ethtool.c |    4 +++-
 drivers/net/benet/be_main.c    |   10 +++++-----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 0f46366..b4be027 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -549,7 +549,9 @@ be_test_ddr_dma(struct be_adapter *adapter)
 {
 	int ret, i;
 	struct be_dma_mem ddrdma_cmd;
-	u64 pattern[2] = {0x5a5a5a5a5a5a5a5aULL, 0xa5a5a5a5a5a5a5a5ULL};
+	static const u64 pattern[2] = {
+		0x5a5a5a5a5a5a5a5aULL, 0xa5a5a5a5a5a5a5a5ULL
+	};
 
 	ddrdma_cmd.size = sizeof(struct be_cmd_req_ddrdma_test);
 	ddrdma_cmd.va = pci_alloc_consistent(adapter->pdev, ddrdma_cmd.size,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index c36cd2f..a112b75 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2343,10 +2343,10 @@ static int be_flash_data(struct be_adapter *adapter,
 	int num_bytes;
 	const u8 *p = fw->data;
 	struct be_cmd_write_flashrom *req = flash_cmd->va;
-	struct flash_comp *pflashcomp;
+	const struct flash_comp *pflashcomp;
 	int num_comp;
 
-	struct flash_comp gen3_flash_types[9] = {
+	static const struct flash_comp gen3_flash_types[9] = {
 		{ FLASH_iSCSI_PRIMARY_IMAGE_START_g3, IMG_TYPE_ISCSI_ACTIVE,
 			FLASH_IMAGE_MAX_SIZE_g3},
 		{ FLASH_REDBOOT_START_g3, IMG_TYPE_REDBOOT,
@@ -2366,7 +2366,7 @@ static int be_flash_data(struct be_adapter *adapter,
 		{ FLASH_NCSI_START_g3, IMG_TYPE_NCSI_FW,
 			FLASH_NCSI_IMAGE_MAX_SIZE_g3}
 	};
-	struct flash_comp gen2_flash_types[8] = {
+	static const struct flash_comp gen2_flash_types[8] = {
 		{ FLASH_iSCSI_PRIMARY_IMAGE_START_g2, IMG_TYPE_ISCSI_ACTIVE,
 			FLASH_IMAGE_MAX_SIZE_g2},
 		{ FLASH_REDBOOT_START_g2, IMG_TYPE_REDBOOT,
@@ -2388,11 +2388,11 @@ static int be_flash_data(struct be_adapter *adapter,
 	if (adapter->generation == BE_GEN3) {
 		pflashcomp = gen3_flash_types;
 		filehdr_size = sizeof(struct flash_file_hdr_g3);
-		num_comp = 9;
+		num_comp = ARRAY_SIZE(gen3_flash_types);
 	} else {
 		pflashcomp = gen2_flash_types;
 		filehdr_size = sizeof(struct flash_file_hdr_g2);
-		num_comp = 8;
+		num_comp = ARRAY_SIZE(gen2_flash_types);
 	}
 	for (i = 0; i < num_comp; i++) {
 		if ((pflashcomp[i].optype == IMG_TYPE_NCSI_FW) &&
-- 
1.7.3.2.245.g03276.dirty

From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 7/8] bnx2: Use const on flash_table structure.
Date: Fri, 21 Aug 2009 19:20:49 -0700
Message-ID: <1250907650-24672-7-git-send-email-mchan@broadcom.com>
References: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2874 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933154AbZHVCNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 22:13:47 -0400
In-Reply-To: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The structure, once initialized, never changes.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    6 +++---
 drivers/net/bnx2.h |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ea6e6b7..58ab3f4 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -145,7 +145,7 @@ static DEFINE_PCI_DEVICE_TABLE(bnx2_pci_tbl) = {
 	{ 0, }
 };
 
-static struct flash_spec flash_table[] =
+static const struct flash_spec flash_table[] =
 {
 #define BUFFERED_FLAGS		(BNX2_NV_BUFFERED | BNX2_NV_TRANSLATE)
 #define NONBUFFERED_FLAGS	(BNX2_NV_WREN)
@@ -234,7 +234,7 @@ static struct flash_spec flash_table[] =
 	 "Buffered flash (256kB)"},
 };
 
-static struct flash_spec flash_5709 = {
+static const struct flash_spec flash_5709 = {
 	.flags		= BNX2_NV_BUFFERED,
 	.page_bits	= BCM5709_FLASH_PAGE_BITS,
 	.page_size	= BCM5709_FLASH_PAGE_SIZE,
@@ -4227,7 +4227,7 @@ bnx2_init_nvram(struct bnx2 *bp)
 {
 	u32 val;
 	int j, entry_count, rc = 0;
-	struct flash_spec *flash;
+	const struct flash_spec *flash;
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
 		bp->flash_info = &flash_5709;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 3c004b4..7544188 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6889,7 +6889,7 @@ struct bnx2 {
 	int			pm_cap;
 	int			pcix_cap;
 
-	struct flash_spec	*flash_info;
+	const struct flash_spec	*flash_info;
 	u32			flash_size;
 
 	int			status_stats_size;
-- 
1.5.6.GIT



From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] rsi: bool tests do not need comparison
Date: Sat, 19 Dec 2015 17:39:45 +0100
Message-ID: <1450543185-27565-1-git-send-email-hofrat@osadl.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an API consolidation only. Bool initializations should 
use true and false thus bool tests don't need an explicit comparison.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Found by coccinelle: scripts/coccinelle/misc/boolinit.cocci

Patch was compile tested with: x86_64_defconfig +
CONFIG_RSI_91X=m

Patch is against linux-next (localversion-next is -next-20151218)

 drivers/net/wireless/rsi/rsi_91x_mgmt.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_mgmt.c b/drivers/net/wireless/rsi/rsi_91x_mgmt.c
index 8d110fd..90161aa 100644
--- a/drivers/net/wireless/rsi/rsi_91x_mgmt.c
+++ b/drivers/net/wireless/rsi/rsi_91x_mgmt.c
@@ -1227,7 +1227,7 @@ int rsi_send_block_unblock_frame(struct rsi_common *common, bool block_event)
 	mgmt_frame->desc_word[0] = cpu_to_le16(RSI_WIFI_MGMT_Q << 12);
 	mgmt_frame->desc_word[1] = cpu_to_le16(BLOCK_HW_QUEUE);
 
-	if (block_event == true) {
+	if (block_event) {
 		rsi_dbg(INFO_ZONE, "blocking the data qs\n");
 		mgmt_frame->desc_word[4] = cpu_to_le16(0xf);
 	} else {
-- 
1.7.10.4

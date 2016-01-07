From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] iwl4965: Fix a memory leak in error handling code of __il4965_up
Date: Thu,  7 Jan 2016 20:17:39 +0800
Message-ID: <1452169059-20617-1-git-send-email-baijiaju1990@163.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jia-Ju Bai <baijiaju1990@163.com>
To: sgruszka@redhat.com, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When il4965_hw_nic_init in __il4965_up fails, the memory allocated by 
iwl4965_sta_alloc_lq in iwl4965_alloc_bcast_station is not freed.

This patches adds il_dealloc_bcast_stations in the error handling code of 
__il4965_up to fix this problem.

This patch has been tested in real device, and it actually fixes the bug.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/wireless/iwlegacy/4965-mac.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index 6656215..fd7b5c7 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -5577,6 +5577,7 @@ __il4965_up(struct il_priv *il)
 	ret = il4965_hw_nic_init(il);
 	if (ret) {
 		IL_ERR("Unable to init nic\n");
+		il_dealloc_bcast_stations(il);
 		return ret;
 	}
 
-- 
1.7.9.5

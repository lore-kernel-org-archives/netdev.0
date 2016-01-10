From: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Subject: [PATCH] iwl4965: Fix a memory leak in error handling code of __il4965_up
Date: Sun, 10 Jan 2016 10:19:23 +0800
Message-ID: <1452392363-3600-1-git-send-email-baijiaju1990@163.com>
Cc: ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
To: sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When il4965_hw_nic_init in __il4965_up fails, the memory allocated by 
iwl4965_sta_alloc_lq in iwl4965_alloc_bcast_station is not freed.

This patches adds il_dealloc_bcast_stations in the error handling code of 
__il4965_up to fix this problem.

This patch has been tested in real device, and it actually fixes the bug.

Signed-off-by: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
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


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

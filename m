From: Vladimir Murzin <murzin.v@gmail.com>
Subject: [PATCH 2/3] wl12xx/wl18xx: limit base for aggregate buffer size to 4K
Date: Thu, 12 Sep 2013 17:32:22 +0200
Message-ID: <1378999943-1968-3-git-send-email-murzin.v@gmail.com>
References: <1378999943-1968-1-git-send-email-murzin.v@gmail.com>
Cc: coelho@ti.com, linville@tuxdriver.com,
	Vladimir Murzin <murzin.v@gmail.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:43769 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738Ab3ILPeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 11:34:06 -0400
In-Reply-To: <1378999943-1968-1-git-send-email-murzin.v@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

WL{12,18}XX_AGGR_BUFFER_SIZE is depends on PAGE_SIZE which may be more
than 4K. In this case memory might be aggressively wasted.

Use 4K size base for buffer explicitly.

Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
---
 drivers/net/wireless/ti/wl12xx/wl12xx.h |    3 ++-
 drivers/net/wireless/ti/wl18xx/wl18xx.h |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ti/wl12xx/wl12xx.h b/drivers/net/wireless/ti/wl12xx/wl12xx.h
index 9e5484a..3649d40 100644
--- a/drivers/net/wireless/ti/wl12xx/wl12xx.h
+++ b/drivers/net/wireless/ti/wl12xx/wl12xx.h
@@ -56,7 +56,8 @@
 #define WL128X_SUBTYPE_MR_VER	WLCORE_FW_VER_IGNORE
 #define WL128X_MINOR_MR_VER	42
 
-#define WL12XX_AGGR_BUFFER_SIZE	(4 * PAGE_SIZE)
+#define WL12XX_PAGE_SIZE	4096
+#define WL12XX_AGGR_BUFFER_SIZE	(4 * WL12XX_PAGE_SIZE)
 
 #define WL12XX_NUM_TX_DESCRIPTORS 16
 #define WL12XX_NUM_RX_DESCRIPTORS 8
diff --git a/drivers/net/wireless/ti/wl18xx/wl18xx.h b/drivers/net/wireless/ti/wl18xx/wl18xx.h
index 9204e07..a3214b4 100644
--- a/drivers/net/wireless/ti/wl18xx/wl18xx.h
+++ b/drivers/net/wireless/ti/wl18xx/wl18xx.h
@@ -33,7 +33,8 @@
 
 #define WL18XX_CMD_MAX_SIZE          740
 
-#define WL18XX_AGGR_BUFFER_SIZE		(13 * PAGE_SIZE)
+#define WL18XX_PAGE_SIZE		4096
+#define WL18XX_AGGR_BUFFER_SIZE		(13 * WL18XX_PAGE_SIZE)
 
 #define WL18XX_NUM_TX_DESCRIPTORS 32
 #define WL18XX_NUM_RX_DESCRIPTORS 32
-- 
1.7.10.4

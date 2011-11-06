From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] net, wireless, mwifiex: Fix mem leak in
 mwifiex_update_curr_bss_params()
Date: Sun, 6 Nov 2011 22:58:31 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1111062255310.5763@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Bing Zhao <bzhao@marvell.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If kmemdup() fails we leak the memory allocated to bss_desc.
This patch fixes the leak.
I also removed the pointless default assignment of 'NULL' to 'bss_desc' 
while I was there anyway.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/wireless/mwifiex/scan.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

 note: patch is compile tested only since I don't have the hardware.

diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwifiex/scan.c
index dae8dbb..8a3f959 100644
--- a/drivers/net/wireless/mwifiex/scan.c
+++ b/drivers/net/wireless/mwifiex/scan.c
@@ -1469,7 +1469,7 @@ mwifiex_update_curr_bss_params(struct mwifiex_private *priv, u8 *bssid,
 			       s32 rssi, const u8 *ie_buf, size_t ie_len,
 			       u16 beacon_period, u16 cap_info_bitmap, u8 band)
 {
-	struct mwifiex_bssdescriptor *bss_desc = NULL;
+	struct mwifiex_bssdescriptor *bss_desc;
 	int ret;
 	unsigned long flags;
 	u8 *beacon_ie;
@@ -1484,6 +1484,7 @@ mwifiex_update_curr_bss_params(struct mwifiex_private *priv, u8 *bssid,
 
 	beacon_ie = kmemdup(ie_buf, ie_len, GFP_KERNEL);
 	if (!beacon_ie) {
+		kfree(bss_desc);
 		dev_err(priv->adapter->dev, " failed to alloc beacon_ie\n");
 		return -ENOMEM;
 	}
-- 
1.7.7.2


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

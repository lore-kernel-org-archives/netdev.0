From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] wireless, wl1251: Fix potential NULL pointer dereference in
 wl1251_op_bss_info_changed()
Date: Thu, 3 Feb 2011 21:14:01 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1102032100460.15101@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Kalle Valo <kvalo@adurom.com>
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In drivers/net/wireless/wl1251/main.c:wl1251_op_bss_info_changed() we make 
a call to ieee80211_beacon_get() which may return NULL, but we do not 
check the return value before dereferencing the pointer.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 main.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/wireless/wl1251/main.c b/drivers/net/wireless/wl1251/main.c
index 012e1a4..40372ba 100644
--- a/drivers/net/wireless/wl1251/main.c
+++ b/drivers/net/wireless/wl1251/main.c
@@ -1039,6 +1039,9 @@ static void wl1251_op_bss_info_changed(struct ieee80211_hw *hw,
 
 	if (changed & BSS_CHANGED_BEACON) {
 		beacon = ieee80211_beacon_get(hw, vif);
+		if (!beacon)
+			goto out_sleep;
+
 		ret = wl1251_cmd_template_set(wl, CMD_BEACON, beacon->data,
 					      beacon->len);
 

-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

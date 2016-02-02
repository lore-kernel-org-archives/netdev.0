From: Byeoungwook Kim <quddnr145@gmail.com>
Subject: [PATCH] rtlwifi: Fix reusable codes in core.c
Date: Wed, 3 Feb 2016 00:48:55 +0900
Message-ID: <20160202154855.GA8990@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rtl_*_delay() functions were reused same codes about addr variable.
So i have converted to rtl_addr_delay() from code about addr variable.

Conditional codes in rtl_addr_delay() were improved in readability and
performance by using switch codes.

Signed-off-by: Byeoungwook Kim <quddnr145@gmail.com>
---
 drivers/net/wireless/realtek/rtlwifi/core.c | 48 +++++++++++------------------
 1 file changed, 18 insertions(+), 30 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
index 4ae421e..c1193d1 100644
--- a/drivers/net/wireless/realtek/rtlwifi/core.c
+++ b/drivers/net/wireless/realtek/rtlwifi/core.c
@@ -37,36 +37,34 @@
 
 void rtl_addr_delay(u32 addr)
 {
-	if (addr == 0xfe)
+	switch (addr) {
+	case 0xfe:
 		mdelay(50);
-	else if (addr == 0xfd)
+		break;
+	case 0xfd:
 		mdelay(5);
-	else if (addr == 0xfc)
+		break;
+	case 0xfc:
 		mdelay(1);
-	else if (addr == 0xfb)
+		break;
+	case 0xfb:
 		udelay(50);
-	else if (addr == 0xfa)
+		break;
+	case 0xfa:
 		udelay(5);
-	else if (addr == 0xf9)
+		break;
+	case 0xf9:
 		udelay(1);
+		break;
+	};
 }
 EXPORT_SYMBOL(rtl_addr_delay);
 
 void rtl_rfreg_delay(struct ieee80211_hw *hw, enum radio_path rfpath, u32 addr,
 		     u32 mask, u32 data)
 {
-	if (addr == 0xfe) {
-		mdelay(50);
-	} else if (addr == 0xfd) {
-		mdelay(5);
-	} else if (addr == 0xfc) {
-		mdelay(1);
-	} else if (addr == 0xfb) {
-		udelay(50);
-	} else if (addr == 0xfa) {
-		udelay(5);
-	} else if (addr == 0xf9) {
-		udelay(1);
+	if (addr >= 0xf9 && addr <= 0xfe) {
+		rtl_addr_delay(addr);
 	} else {
 		rtl_set_rfreg(hw, rfpath, addr, mask, data);
 		udelay(1);
@@ -76,18 +74,8 @@ EXPORT_SYMBOL(rtl_rfreg_delay);
 
 void rtl_bb_delay(struct ieee80211_hw *hw, u32 addr, u32 data)
 {
-	if (addr == 0xfe) {
-		mdelay(50);
-	} else if (addr == 0xfd) {
-		mdelay(5);
-	} else if (addr == 0xfc) {
-		mdelay(1);
-	} else if (addr == 0xfb) {
-		udelay(50);
-	} else if (addr == 0xfa) {
-		udelay(5);
-	} else if (addr == 0xf9) {
-		udelay(1);
+	if (addr >= 0xf9 && addr <= 0xfe) {
+		rtl_addr_delay(addr);
 	} else {
 		rtl_set_bbreg(hw, addr, MASKDWORD, data);
 		udelay(1);
-- 
2.5.0

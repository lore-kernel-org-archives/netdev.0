From: Tim Gardner <tim.gardner@canonical.com>
Subject: [PATCH wireless-next] brcmsmac: fix u16 overflow warning
Date: Thu,  7 Feb 2013 12:35:35 -0700
Message-ID: <1360265735-42450-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner@canonical.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DOT11_MIN_BEACON_PERIOD and DOT11_MAX_BEACON_PERIOD are
superfluous. The only invalid beacon period is 0. Comparing
a 16 bit quantity to 0xffff also causes a compile warning:

drivers/net/wireless/brcm80211/brcmsmac/main.c:5560 brcms_c_set_beacon_period()
 warn: impossible condition '(period > 65535) => (0-65535 > 65535)'

Observed from smatch analysis.

Cc: Brett Rudley <brudley@broadcom.com>
Cc: Arend van Spriel <arend@broadcom.com>
Cc: "Franky (Zhenhui) Lin" <frankyl@broadcom.com>
Cc: Hante Meuleman <meuleman@broadcom.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: Pieter-Paul Giesberts <pieterpg@broadcom.com>
Cc: Seth Forshee <seth.forshee@canonical.com>
Cc: Hauke Mehrtens <hauke@hauke-m.de>
Cc: linux-wireless@vger.kernel.org
Cc: brcm80211-dev-list@broadcom.com
Cc: netdev@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/net/wireless/brcm80211/brcmsmac/main.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index c26992a..080b54d 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -101,8 +101,6 @@
 #define DOT11_RTS_LEN			16
 #define DOT11_CTS_LEN			10
 #define DOT11_BA_BITMAP_LEN		128
-#define DOT11_MIN_BEACON_PERIOD		1
-#define DOT11_MAX_BEACON_PERIOD		0xFFFF
 #define DOT11_MAXNUMFRAGS		16
 #define DOT11_MAX_FRAG_LEN		2346
 
@@ -5555,8 +5553,7 @@ int brcms_c_set_rateset(struct brcms_c_info *wlc, struct brcm_rateset *rs)
 
 int brcms_c_set_beacon_period(struct brcms_c_info *wlc, u16 period)
 {
-	if (period < DOT11_MIN_BEACON_PERIOD ||
-	    period > DOT11_MAX_BEACON_PERIOD)
+	if (period == 0)
 		return -EINVAL;
 
 	wlc->default_bss->beacon_period = period;
-- 
1.7.9.5

From: Olivier Langlois <olivier@trillion01.com>
Subject: [PATCH 2/2] retry hw init when it fails
Date: Fri, 31 Jan 2014 00:16:23 -0500
Message-ID: <1391145383-18652-2-git-send-email-olivier@trillion01.com>
References: <1391145383-18652-1-git-send-email-olivier@trillion01.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	Olivier Langlois <olivier@trillion01.com>
To: Larry.Finger@lwfinger.net, linville@tuxdriver.com,
	chaoming_li@realsil.com.cn
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1391145383-18652-1-git-send-email-olivier@trillion01.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rtl_ps_enable_nic() is called from loops that will loop until this function returns true or a
maximum number of retries is performed.

hw_init() returns non-zero on error. In that situation return false to
restore the original design intent to retry hw init when it fails.

Signed-off-by: Olivier Langlois <olivier@trillion01.com>
---
 drivers/net/wireless/rtlwifi/ps.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index 0d81f76..a56e9b3 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -48,7 +48,7 @@ bool rtl_ps_enable_nic(struct ieee80211_hw *hw)
 
 	/*<2> Enable Adapter */
 	if (rtlpriv->cfg->ops->hw_init(hw))
-		return 1;
+		return false;
 	RT_CLEAR_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
 
 	/*<3> Enable Interrupt */
-- 
1.8.5.2

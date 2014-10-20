From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] rtlwifi: prevent format string usage from leaking
Date: Mon, 20 Oct 2014 14:57:08 -0700
Message-ID: <20141020215708.GA32650@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use "%s" in the workqueue allocation to make sure the rtl_hal_cfg name
can never accidentally leak information via a format string.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wireless/rtlwifi/base.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 58ba71830886..40b6d1d006d7 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -467,7 +467,7 @@ static void _rtl_init_deferred_work(struct ieee80211_hw *hw)
 		    rtl_easy_concurrent_retrytimer_callback, (unsigned long)hw);
 	/* <2> work queue */
 	rtlpriv->works.hw = hw;
-	rtlpriv->works.rtl_wq = alloc_workqueue(rtlpriv->cfg->name, 0, 0);
+	rtlpriv->works.rtl_wq = alloc_workqueue("%s", 0, 0, rtlpriv->cfg->name);
 	INIT_DELAYED_WORK(&rtlpriv->works.watchdog_wq,
 			  (void *)rtl_watchdog_wq_callback);
 	INIT_DELAYED_WORK(&rtlpriv->works.ips_nic_off_wq,
-- 
1.9.1


-- 
Kees Cook
Chrome OS Security

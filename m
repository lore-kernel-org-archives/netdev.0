From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] rtlwifi: rtl818x: silence uninitialized variable warning
Date: Wed, 4 May 2016 09:16:39 +0300
Message-ID: <20160504061639.GB22064@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What about if "rtlphy->pwrgroup_cnt" is 2?  In that case we would use an
uninitialized "chnlgroup" variable and probably crash.  Maybe that can't
happen for some reason which is not obvious but in that case this patch
is harmless.

Setting it to zero seems like a standard default in the surrounding code
so it's probably fine here as well.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/rf.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/rf.c
index 78a81c1..9475aa2 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192se/rf.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192se/rf.c
@@ -208,8 +208,7 @@ static void _rtl92s_get_txpower_writeval_byregulatory(struct ieee80211_hw *hw,
 				 "Realtek regulatory, 40MHz, writeval = 0x%x\n",
 				 writeval);
 		} else {
-			if (rtlphy->pwrgroup_cnt == 1)
-				chnlgroup = 0;
+			chnlgroup = 0;
 
 			if (rtlphy->pwrgroup_cnt >= 3) {
 				if (chnl <= 3)

From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 1/1] net: wireless: marvell: fix improper return value
Date: Sat,  3 Dec 2016 18:27:37 +0800
Message-ID: <1480760857-4549-1-git-send-email-bianpan2016@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Kalle Valo <kvalo@codeaurora.org>,
        Andreas Kemnade <andreas@kemnade.info>,
        Johannes Berg <johannes.berg@intel.com>,
        libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Function lbs_cmd_802_11_sleep_params() always return 0, even if the call
to lbs_cmd_with_response() fails. In this case, the parameter @sp will
keep uninitialized. Because the return value is 0, its caller (say
lbs_sleepparams_read()) will not detect the error, and will copy the
uninitialized stack memory to user sapce, resulting in stack information
leak. To avoid the bug, this patch returns variable ret (which takes
the return value of lbs_cmd_with_response()) instead of 0.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188451

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/wireless/marvell/libertas/cmd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/libertas/cmd.c b/drivers/net/wireless/marvell/libertas/cmd.c
index 301170c..033ff88 100644
--- a/drivers/net/wireless/marvell/libertas/cmd.c
+++ b/drivers/net/wireless/marvell/libertas/cmd.c
@@ -305,7 +305,7 @@ int lbs_cmd_802_11_sleep_params(struct lbs_private *priv, uint16_t cmd_action,
 	}
 
 	lbs_deb_leave_args(LBS_DEB_CMD, "ret %d", ret);
-	return 0;
+	return ret;
 }
 
 static int lbs_wait_for_ds_awake(struct lbs_private *priv)
-- 
1.9.1

From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 1/1] net: wireless: intersil: fix improper return value
Date: Sat,  3 Dec 2016 18:18:40 +0800
Message-ID: <1480760320-4380-1-git-send-email-bianpan2016@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Function orinoco_ioctl_commit() returns 0 (indicates success) when the
call to orinoco_lock() fails. Thus, the return value is inconsistent with
the execution status. It may be better to return "-EBUSY" when the call 
to orinoco_lock() fails.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188671

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/wireless/intersil/orinoco/wext.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/intersil/orinoco/wext.c b/drivers/net/wireless/intersil/orinoco/wext.c
index 1d4dae4..fee57ea 100644
--- a/drivers/net/wireless/intersil/orinoco/wext.c
+++ b/drivers/net/wireless/intersil/orinoco/wext.c
@@ -1314,7 +1314,7 @@ static int orinoco_ioctl_commit(struct net_device *dev,
 		return 0;
 
 	if (orinoco_lock(priv, &flags) != 0)
-		return err;
+		return -EBUSY;
 
 	err = orinoco_commit(priv);
 
-- 
1.9.1

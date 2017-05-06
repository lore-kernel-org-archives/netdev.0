From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] wil6210: use memdup_user
Date: Sat,  6 May 2017 23:42:19 +0800
Message-ID: <b5b672573585b51a3acb37231f38db45f5873f60.1493781695.git.geliangtang@gmail.com>
References: <df8091d4c64a0d5a7ab0a5989f34552a5eebd15e.1493778999.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>,
        linux-wireless@vger.kernel.org, wil6210@qca.qualcomm.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Maya Erez <qca_merez@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <df8091d4c64a0d5a7ab0a5989f34552a5eebd15e.1493778999.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use memdup_user() helper instead of open-coding to simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/net/wireless/ath/wil6210/debugfs.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/wil6210/debugfs.c b/drivers/net/wireless/ath/wil6210/debugfs.c
index 5648ebb..5b0f9fc 100644
--- a/drivers/net/wireless/ath/wil6210/debugfs.c
+++ b/drivers/net/wireless/ath/wil6210/debugfs.c
@@ -795,15 +795,11 @@ static ssize_t wil_write_file_txmgmt(struct file *file, const char __user *buf,
 	struct wireless_dev *wdev = wil_to_wdev(wil);
 	struct cfg80211_mgmt_tx_params params;
 	int rc;
-	void *frame = kmalloc(len, GFP_KERNEL);
+	void *frame;
 
-	if (!frame)
-		return -ENOMEM;
-
-	if (copy_from_user(frame, buf, len)) {
-		kfree(frame);
-		return -EIO;
-	}
+	frame = memdup_user(buf, len);
+	if (IS_ERR(frame))
+		return PTR_ERR(frame);
 
 	params.buf = frame;
 	params.len = len;
-- 
2.9.3

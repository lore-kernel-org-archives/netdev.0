From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/3] ath9k: Adjust a null pointer check in three functions
Date: Tue, 9 May 2017 09:29:04 +0200
Message-ID: <6c3d87e0-d758-6f9b-4b1f-156d890b788d@users.sourceforge.net>
References: <03575993-754d-924c-9736-2a8d19e98fa5@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: ath9k-devel@qca.qualcomm.com, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <03575993-754d-924c-9736-2a8d19e98fa5@users.sourceforge.net>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 8 May 2017 22:17:13 +0200

The script "checkpatch.pl" pointed information out like the following.

Comparison to NULL could be written "!buf"

Thus adjust this expression.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/ath/ath9k/debug.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
index 0d215598193c..5f2c1d8e8e70 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -161,7 +161,7 @@ static ssize_t read_file_ani(struct file *file, char __user *user_buf,
 	};
 
 	buf = kzalloc(size, GFP_KERNEL);
-	if (buf == NULL)
+	if (!buf)
 		return -ENOMEM;
 
 	len += scnprintf(buf + len, size - len, "%15s: %s\n", "ANI",
@@ -315,7 +315,7 @@ static ssize_t read_file_antenna_diversity(struct file *file,
 	};
 
 	buf = kzalloc(size, GFP_KERNEL);
-	if (buf == NULL)
+	if (!buf)
 		return -ENOMEM;
 
 	if (!(pCap->hw_caps & ATH9K_HW_CAP_ANT_DIV_COMB)) {
@@ -1008,7 +1008,7 @@ static ssize_t read_file_btcoex(struct file *file, char __user *user_buf,
 	size_t retval;
 
 	buf = kzalloc(size, GFP_KERNEL);
-	if (buf == NULL)
+	if (!buf)
 		return -ENOMEM;
 
 	if (!sc->sc_ah->common.btcoex_enabled) {
-- 
2.12.2


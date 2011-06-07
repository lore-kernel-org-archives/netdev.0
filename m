From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH] net/mac80211/debugfs: Convert to kstrou8_from_user
Date: Tue,  7 Jun 2011 22:36:14 +0200
Message-ID: <1307478974-32727-1-git-send-email-peterhuewe@gmx.de>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Peter Huewe <peterhuewe@gmx.de>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces the code for getting an number from a
userspace buffer by a simple call to kstrou8_from_user.
This makes it easier to read and less error prone.

Since the old buffer was only 10 bytes long and the value is masked by a
nibble-mask anyway, we don't need to use kstrtoul but rather kstrtou8.

Kernel Version: v3.0-rc2

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 net/mac80211/debugfs.c |   14 +++-----------
 1 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
index 186e02f..267ed45 100644
--- a/net/mac80211/debugfs.c
+++ b/net/mac80211/debugfs.c
@@ -195,20 +195,12 @@ static ssize_t uapsd_queues_write(struct file *file,
 				  size_t count, loff_t *ppos)
 {
 	struct ieee80211_local *local = file->private_data;
-	unsigned long val;
-	char buf[10];
-	size_t len;
+	u8 val;
 	int ret;
 
-	len = min(count, sizeof(buf) - 1);
-	if (copy_from_user(buf, user_buf, len))
-		return -EFAULT;
-	buf[len] = '\0';
-
-	ret = strict_strtoul(buf, 0, &val);
-
+	ret = kstrtou8_from_user(user_buf, count, 0, &val);
 	if (ret)
-		return -EINVAL;
+		return ret;
 
 	if (val & ~IEEE80211_WMM_IE_STA_QOSINFO_AC_MASK)
 		return -ERANGE;
-- 
1.7.3.4

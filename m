From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] at86rf230: fix build warning
Date: Fri, 11 Sep 2015 15:16:04 +0530
Message-ID: <1441964764-15611-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-wpan@vger.kernel.org,
	netdev@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

e616a00ce786 ("drivers/net/ieee802154/at86rf230.c: seq_printf() now returns NULL")
has removed the usage of the integer "ret" but missed removing the
variable. And we were getting a build warning about "unused variable".

Fixes: e616a00ce786 ("drivers/net/ieee802154/at86rf230.c: seq_printf() now returns NULL")
Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 drivers/net/ieee802154/at86rf230.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index a9f3af6..9ae98fd 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -1645,7 +1645,6 @@ static struct dentry *at86rf230_debugfs_root;
 static int at86rf230_stats_show(struct seq_file *file, void *offset)
 {
 	struct at86rf230_local *lp = file->private;
-	int ret;
 
 	seq_printf(file, "SUCCESS:\t\t%8llu\n", lp->trac.success);
 	seq_printf(file, "SUCCESS_DATA_PENDING:\t%8llu\n",
-- 
1.9.1

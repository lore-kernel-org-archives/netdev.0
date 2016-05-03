From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 12/15] batman-adv: fix debuginfo macro style issue
Date: Wed,  4 May 2016 06:23:47 +0800
Message-ID: <1462314230-16257-13-git-send-email-a__44943.6753908687$1462315908$gmane$org@unstable.cc>
References: <1462314230-16257-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@open-mesh.com>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:30398 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756519AbcECWvk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:51:40 -0400
In-Reply-To: <1462314230-16257-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@open-mesh.com>

Structure initialization within the macros should follow the general
coding style used in the kernel: put the initialization of the first
variable and the closing brace on a separate line.

Reported-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Simon Wunderlich <simon.wunderlich@open-mesh.com>
[sven@narfation.org: fix conflicts with current version]
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/debugfs.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/debugfs.c b/net/batman-adv/debugfs.c
index 48253cf8341b..aa315da83429 100644
--- a/net/batman-adv/debugfs.c
+++ b/net/batman-adv/debugfs.c
@@ -365,14 +365,17 @@ static int batadv_nc_nodes_open(struct inode *inode, struct file *file)
 
 #define BATADV_DEBUGINFO(_name, _mode, _open)		\
 struct batadv_debuginfo batadv_debuginfo_##_name = {	\
-	.attr = { .name = __stringify(_name),		\
-		  .mode = _mode, },			\
-	.fops = { .owner = THIS_MODULE,			\
-		  .open = _open,			\
-		  .read	= seq_read,			\
-		  .llseek = seq_lseek,			\
-		  .release = single_release,		\
-		}					\
+	.attr = {					\
+		.name = __stringify(_name),		\
+		.mode = _mode,				\
+	},						\
+	.fops = {					\
+		.owner = THIS_MODULE,			\
+		.open = _open,				\
+		.read	= seq_read,			\
+		.llseek = seq_lseek,			\
+		.release = single_release,		\
+	},						\
 }
 
 /* the following attributes are general and therefore they will be directly
-- 
2.8.2

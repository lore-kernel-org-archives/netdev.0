From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 063/115] sysctl: simplify find_in_table
Date: Mon,  9 May 2011 00:39:15 +0200
Message-ID: <1304894407-32201-64-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The if (!p->procname) check is useless because the loop condition
prevents it from happening.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/proc/proc_sysctl.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index f50133c..d1640bc 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -52,18 +52,12 @@ static struct ctl_table *find_in_table(struct ctl_table *p, struct qstr *name)
 	int len;
 	for ( ; p->procname; p++) {
 
-		if (!p->procname)
-			continue;
-
 		len = strlen(p->procname);
 		if (len != name->len)
 			continue;
 
-		if (memcmp(p->procname, name->name, len) != 0)
-			continue;
-
-		/* I have a match */
-		return p;
+		if (memcmp(p->procname, name->name, len) == 0)
+			return p;
 	}
 	return NULL;
 }
-- 
1.7.5.134.g1c08b

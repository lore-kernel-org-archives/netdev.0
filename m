From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 01/29] sysctl: remove impossible condition check
Date: Thu, 26 Jan 2012 20:49:42 -0800
Message-ID: <1327639810-12760-1-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lucas De Marchi <lucas.demarchi@profusion.mobi>

Remove checks for conditions that will never happen. If procname is NULL
the loop would already had bailed out, so there's no need to check it
again.

At the same time this also compacts the function find_in_table() by
refactoring it to be easier to read.

Signed-off-by: Lucas De Marchi <lucas.demarchi@profusion.mobi>
Reviewed-by: Jesper Juhl <jj@chaosbits.net>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index a6b6217..d82f4a8 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -59,17 +59,11 @@ out:
 
 static struct ctl_table *find_in_table(struct ctl_table *p, struct qstr *name)
 {
-	int len;
 	for ( ; p->procname; p++) {
-
-		if (!p->procname)
-			continue;
-
-		len = strlen(p->procname);
-		if (len != name->len)
+		if (strlen(p->procname) != name->len)
 			continue;
 
-		if (memcmp(p->procname, name->name, len) != 0)
+		if (memcmp(p->procname, name->name, name->len) != 0)
 			continue;
 
 		/* I have a match */
@@ -266,10 +260,6 @@ static int scan(struct ctl_table_header *head, ctl_table *table,
 	for (; table->procname; table++, (*pos)++) {
 		int res;
 
-		/* Can't do anything without a proc name */
-		if (!table->procname)
-			continue;
-
 		if (*pos < file->f_pos)
 			continue;
 
-- 
1.7.2.5

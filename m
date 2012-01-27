From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 29/29] sysctl: Add register_sysctl for normal sysctl users
Date: Thu, 26 Jan 2012 20:50:10 -0800
Message-ID: <1327639810-12760-29-git-send-email-ebiederm@xmission.com>
References: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Cc: <linux-fsdevel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Damien Millescamps <damien.millescamps@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1pqe5ah3z.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The plan is to convert all callers of register_sysctl_table
and register_sysctl_paths to register_sysctl.  The interface
to register_sysctl is enough nicer this should make the callers
a bit more readable.  Additionally after the conversion the
230 lines of backwards compatibility can be removed.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/proc_sysctl.c  |   17 +++++++++++++++++
 include/linux/sysctl.h |    1 +
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 05c393a..8dc7f0e 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -1228,6 +1228,23 @@ fail:
 	return NULL;
 }
 
+/**
+ * register_sysctl - register a sysctl table
+ * @path: The path to the directory the sysctl table is in.
+ * @table: the table structure
+ *
+ * Register a sysctl table. @table should be a filled in ctl_table
+ * array. A completely 0 filled entry terminates the table.
+ *
+ * See __register_sysctl_table for more details.
+ */
+struct ctl_table_header *register_sysctl(const char *path, struct ctl_table *table)
+{
+	return __register_sysctl_table(&sysctl_table_root.default_set,
+					path, table);
+}
+EXPORT_SYMBOL(register_sysctl);
+
 static char *append_path(const char *path, char *pos, const char *name)
 {
 	int namelen;
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 35c50ed..c34b4c8 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -1090,6 +1090,7 @@ struct ctl_table_header *__register_sysctl_table(
 struct ctl_table_header *__register_sysctl_paths(
 	struct ctl_table_set *set,
 	const struct ctl_path *path, struct ctl_table *table);
+struct ctl_table_header *register_sysctl(const char *path, struct ctl_table *table);
 struct ctl_table_header *register_sysctl_table(struct ctl_table * table);
 struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 						struct ctl_table *table);
-- 
1.7.2.5

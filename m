From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 020/115] sysctl: remove .child from coda/
Date: Mon,  9 May 2011 00:38:32 +0200
Message-ID: <1304894407-32201-21-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/coda/sysctl.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/fs/coda/sysctl.c b/fs/coda/sysctl.c
index af56ad5..8c328c9 100644
--- a/fs/coda/sysctl.c
+++ b/fs/coda/sysctl.c
@@ -39,19 +39,15 @@ static ctl_table coda_table[] = {
 	{}
 };
 
-static ctl_table fs_table[] = {
-	{
-		.procname	= "coda",
-		.mode		= 0555,
-		.child		= coda_table
-	},
-	{}
+static const __initdata struct ctl_path coda_path[] = {
+	{ .procname = "coda" },
+	{ }
 };
 
 void coda_sysctl_init(void)
 {
 	if ( !fs_table_header )
-		fs_table_header = register_sysctl_table(fs_table);
+		fs_table_header = register_sysctl_paths(coda_path, coda_table);
 }
 
 void coda_sysctl_clean(void)
-- 
1.7.5.134.g1c08b

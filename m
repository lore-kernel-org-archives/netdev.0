From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 008/115] sysctl: remove .child from crypto/fips_enabled
Date: Mon,  9 May 2011 00:38:20 +0200
Message-ID: <1304894407-32201-9-git-send-email-lucian.grijincu@gmail.com>
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
 crypto/proc.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/crypto/proc.c b/crypto/proc.c
index 58fef67..2ef248b 100644
--- a/crypto/proc.c
+++ b/crypto/proc.c
@@ -34,20 +34,16 @@ static struct ctl_table crypto_sysctl_table[] = {
 	{}
 };
 
-static struct ctl_table crypto_dir_table[] = {
-	{
-		.procname       = "crypto",
-		.mode           = 0555,
-		.child          = crypto_sysctl_table
-	},
-	{}
+static const struct ctl_path crypto_root_path[] = {
+	{ .procname = "crypto" },
+	{ }
 };
 
 static struct ctl_table_header *crypto_sysctls;
 
 static void crypto_proc_fips_init(void)
 {
-	crypto_sysctls = register_sysctl_table(crypto_dir_table);
+	crypto_sysctls = register_sysctl_paths(crypto_root_path, crypto_sysctl_table);
 }
 
 static void crypto_proc_fips_exit(void)
-- 
1.7.5.134.g1c08b

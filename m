From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 092/115] sysctl: sched: create empty dir with register_sysctl_dir
Date: Mon,  9 May 2011 00:39:44 +0200
Message-ID: <1304894407-32201-93-git-send-email-lucian.grijincu@gmail.com>
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
 kernel/sched.c |   19 ++++---------------
 1 files changed, 4 insertions(+), 15 deletions(-)

diff --git a/kernel/sched.c b/kernel/sched.c
index 8320365..5cda526 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -6302,16 +6302,11 @@ static void register_sched_domain_sysctl(void)
 
 	i = 0;
 	for_each_possible_cpu(cpu) {
-		struct ctl_table *empty = kzalloc(sizeof(*empty), GFP_KERNEL);
-		if (empty == NULL)
-			goto unregister_sd_cpudir_headers;
 		sd_path[SD_PATH_CPU].procname = sd_cpu_names[cpu];
 		sd_path[SD_PATH_DOM].procname = NULL; /* end of array sentinel */
-		sd_cpudir_headers[i] = register_sysctl_paths(sd_path, empty);
-		if (sd_cpudir_headers[i] == NULL) {
-			kfree(empty);
+		sd_cpudir_headers[i] = register_sysctl_dir(sd_path);
+		if (sd_cpudir_headers[i] == NULL)
 			goto unregister_sd_cpudir_headers;
-		}
 		i++;
 	}
 
@@ -6347,11 +6342,8 @@ unregister_sd_domain_headers:
 	i = sd_cpudir_headers_num;
 unregister_sd_cpudir_headers:
 	i--;
-	for(; i >= 0; i--) {
-		struct ctl_table *table = sd_cpudir_headers[i]->ctl_table_arg;
+	for(; i >= 0; i--)
 		unregister_sysctl_table(sd_cpudir_headers[i]);
-		kfree(table);
-	}
 
 	kfree(sd_domain_headers);
 fail_alloc_sd_domain_headers:
@@ -6391,11 +6383,8 @@ static void unregister_sched_domain_sysctl(void)
 		kfree(table);
 	}
 
-	for(i = sd_cpudir_headers_num - 1; i >= 0; i--) {
-		struct ctl_table *table = sd_cpudir_headers[i]->ctl_table_arg;
+	for(i = sd_cpudir_headers_num - 1; i >= 0; i--)
 		unregister_sysctl_table(sd_cpudir_headers[i]);
-		kfree(table);
-	}
 
 	kfree(sd_domain_headers);
 	kfree(sd_cpudir_headers);
-- 
1.7.5.134.g1c08b

From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 010/115] sysctl: remove .child from dev/hpet/
Date: Mon,  9 May 2011 00:38:22 +0200
Message-ID: <1304894407-32201-11-git-send-email-lucian.grijincu@gmail.com>
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
 drivers/char/hpet.c |   38 ++++++++++++--------------------------
 1 files changed, 12 insertions(+), 26 deletions(-)

diff --git a/drivers/char/hpet.c b/drivers/char/hpet.c
index 7066e80..303de7e 100644
--- a/drivers/char/hpet.c
+++ b/drivers/char/hpet.c
@@ -721,33 +721,19 @@ static int hpet_is_known(struct hpet_data *hdp)
 
 static ctl_table hpet_table[] = {
 	{
-	 .procname = "max-user-freq",
-	 .data = &hpet_max_freq,
-	 .maxlen = sizeof(int),
-	 .mode = 0644,
-	 .proc_handler = proc_dointvec,
-	 },
-	{}
+		.procname = "max-user-freq",
+		.data     = &hpet_max_freq,
+		.maxlen   = sizeof(int),
+		.mode     = 0644,
+		.proc_handler = proc_dointvec,
+	},
+	{ }
 };
 
-static ctl_table hpet_root[] = {
-	{
-	 .procname = "hpet",
-	 .maxlen = 0,
-	 .mode = 0555,
-	 .child = hpet_table,
-	 },
-	{}
-};
-
-static ctl_table dev_root[] = {
-	{
-	 .procname = "dev",
-	 .maxlen = 0,
-	 .mode = 0555,
-	 .child = hpet_root,
-	 },
-	{}
+static const struct ctl_path hpet_path[] = {
+	{ .procname = "dev" },
+	{ .procname = "hpet" },
+	{ }
 };
 
 static struct ctl_table_header *sysctl_header;
@@ -1053,7 +1039,7 @@ static int __init hpet_init(void)
 	if (result < 0)
 		return -ENODEV;
 
-	sysctl_header = register_sysctl_table(dev_root);
+	sysctl_header = register_sysctl_paths(hpet_path, hpet_table);
 
 	result = acpi_bus_register_driver(&hpet_acpi_driver);
 	if (result < 0) {
-- 
1.7.5.134.g1c08b

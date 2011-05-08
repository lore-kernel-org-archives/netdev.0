From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 038/115] sysctl: remove .child from reboot/warm (arm)
Date: Mon,  9 May 2011 00:38:50 +0200
Message-ID: <1304894407-32201-39-git-send-email-lucian.grijincu@gmail.com>
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
 arch/arm/mach-bcmring/arch.c |   25 ++++++++++++-------------
 1 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/arch/arm/mach-bcmring/arch.c b/arch/arm/mach-bcmring/arch.c
index 73eb066..33c10fd 100644
--- a/arch/arm/mach-bcmring/arch.c
+++ b/arch/arm/mach-bcmring/arch.c
@@ -55,20 +55,18 @@ static struct ctl_table_header *bcmring_sysctl_header;
 
 static struct ctl_table bcmring_sysctl_warm_reboot[] = {
 	{
-	 .procname = "warm",
-	 .data = &bcmring_arch_warm_reboot,
-	 .maxlen = sizeof(int),
-	 .mode = 0644,
-	 .proc_handler = proc_dointvec},
-	{}
+		.procname = "warm",
+		.data     = &bcmring_arch_warm_reboot,
+		.maxlen   = sizeof(int),
+		.mode     = 0644,
+		.proc_handler = proc_dointvec,
+	},
+	{ }
 };
 
-static struct ctl_table bcmring_sysctl_reboot[] = {
-	{
-	 .procname = "reboot",
-	 .mode = 0555,
-	 .child = bcmring_sysctl_warm_reboot},
-	{}
+static const __initdata struct ctl_path bcmring_sysctl_path[] = {
+	{ .procname = "reboot" },
+	{ }
 };
 
 static struct resource nand_resource[] = {
@@ -117,7 +115,8 @@ static struct platform_device *devices[] __initdata = {
 static void __init bcmring_init_machine(void)
 {
 
-	bcmring_sysctl_header = register_sysctl_table(bcmring_sysctl_reboot);
+	bcmring_sysctl_header = register_sysctl_paths(bcmring_sysctl_path,
+						      bcmring_sysctl_warm_reboot);
 
 	/* Enable spread spectrum */
 	chipcHw_enableSpreadSpectrum();
-- 
1.7.5.134.g1c08b

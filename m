From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/3] ethtool: allow force hex in register dump
Date: Mon, 23 Oct 2006 10:58:37 -0700
Message-ID: <20061023105837.4102f0af@dxpl.pdx.osdl.net>
References: <20061018104632.27a37d75@freekitty>
	<20061018105022.57b57b6a@freekitty>
	<453A63AF.1010505@pobox.com>
	<20061023105142.13b507a7@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:31629 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964985AbWJWSEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2006 14:04:36 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061023105142.13b507a7@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sometimes the device decode logic just gets in the way
so add a "force hex" option to register dump.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 ethtool.8 |    1 +
 ethtool.c |   11 +++++++----
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/ethtool.8 b/ethtool.8
index bffde30..d247d51 100644
--- a/ethtool.8
+++ b/ethtool.8
@@ -126,6 +126,7 @@ ethtool \- Display or change ethernet ca
 .B ethtool \-d|\-\-register\-dump
 .I ethX
 .B2 raw on off
+.B2 hex on off
 .RB [ file 
 .IR name ]
 
diff --git a/ethtool.c b/ethtool.c
index f004d54..06e3675 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -255,6 +255,7 @@ static int msglvl_wanted = -1;
 static int phys_id_time = 0;
 static int gregs_changed = 0;
 static int gregs_dump_raw = 0;
+static int gregs_dump_hex = 0;
 static char *gregs_dump_file = NULL;
 static int geeprom_changed = 0;
 static int geeprom_dump_raw = 0;
@@ -285,6 +286,7 @@ struct cmdline_info {
 
 static struct cmdline_info cmdline_gregs[] = {
 	{ "raw", CMDL_BOOL, &gregs_dump_raw, NULL },
+	{ "hex", CMDL_BOOL, &gregs_dump_hex, NULL },
 	{ "file", CMDL_STR, &gregs_dump_file, NULL },
 };
 
@@ -1000,10 +1002,11 @@ static int dump_regs(struct ethtool_drvi
 		fclose(f);
 	}
 
-	for (i = 0; i < ARRAY_SIZE(driver_list); i++)
-		if (!strncmp(driver_list[i].name, info->driver,
-			     ETHTOOL_BUSINFO_LEN))
-			return driver_list[i].func(info, regs);
+	if (!gregs_dump_hex)
+		for (i = 0; i < ARRAY_SIZE(driver_list); i++)
+			if (!strncmp(driver_list[i].name, info->driver,
+				     ETHTOOL_BUSINFO_LEN))
+				return driver_list[i].func(info, regs);
 
 	fprintf(stdout, "Offset\tValues\n");
 	fprintf(stdout, "--------\t-----");
-- 
1.4.2.3


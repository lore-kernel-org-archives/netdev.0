From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/7] Add output file parameter to dump_hex() and
 make it extern
Date: Sat, 2 Jun 2012 01:36:12 +0100
Message-ID: <1338597372.2770.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Mahesh Bandewar <maheshb@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35787 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760247Ab2FBAgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 20:36:16 -0400
In-Reply-To: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c  |   19 ++++++++++---------
 internal.h |    2 ++
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 65bdd38..9d42ca8 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -787,18 +787,18 @@ static const struct {
 	{ "st_gmac", st_gmac_dump_regs },
 };
 
-static void dump_hex(__u8 *data, int len, int offset)
+void dump_hex(FILE *file, const u8 *data, int len, int offset)
 {
 	int i;
 
-	fprintf(stdout, "Offset\t\tValues\n");
-	fprintf(stdout, "------\t\t------");
+	fprintf(file, "Offset\t\tValues\n");
+	fprintf(file, "------\t\t------");
 	for (i = 0; i < len; i++) {
 		if (i % 16 == 0)
-			fprintf(stdout, "\n0x%04x:\t\t", i + offset);
-		fprintf(stdout, "%02x ", data[i]);
+			fprintf(file, "\n0x%04x:\t\t", i + offset);
+		fprintf(file, "%02x ", data[i]);
 	}
-	fprintf(stdout, "\n");
+	fprintf(file, "\n");
 }
 
 static int dump_regs(int gregs_dump_raw, int gregs_dump_hex,
@@ -834,7 +834,7 @@ static int dump_regs(int gregs_dump_raw, int gregs_dump_hex,
 				     ETHTOOL_BUSINFO_LEN))
 				return driver_list[i].func(info, regs);
 
-	dump_hex(regs->data, regs->len, 0);
+	dump_hex(stdout, regs->data, regs->len, 0);
 
 	return 0;
 }
@@ -853,7 +853,7 @@ static int dump_eeprom(int geeprom_dump_raw, struct ethtool_drvinfo *info,
 		return tg3_dump_eeprom(info, ee);
 	}
 
-	dump_hex(ee->data, ee->len, ee->offset);
+	dump_hex(stdout, ee->data, ee->len, ee->offset);
 
 	return 0;
 }
@@ -3253,7 +3253,8 @@ static int do_getmodule(struct cmd_context *ctx)
 			}
 		}
 		if (geeprom_dump_hex)
-			dump_hex(eeprom->data, eeprom->len, eeprom->offset);
+			dump_hex(stdout, eeprom->data,
+				 eeprom->len, eeprom->offset);
 	}
 
 	free(eeprom);
diff --git a/internal.h b/internal.h
index 10abe25..b013783 100644
--- a/internal.h
+++ b/internal.h
@@ -144,6 +144,8 @@ int test_fclose(FILE *fh);
 
 int send_ioctl(struct cmd_context *ctx, void *cmd);
 
+void dump_hex(FILE *f, const u8 *data, int len, int offset);
+
 /* National Semiconductor DP83815, DP83816 */
 int natsemi_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 int natsemi_dump_eeprom(struct ethtool_drvinfo *info,
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

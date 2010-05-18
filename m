From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/2] ethtool: Add generic structure and functions for named
 flags
Date: Tue, 18 May 2010 17:32:16 +0100
Message-ID: <1274200336.2113.0.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:14430 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755525Ab0ERQcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 12:32:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will be used to support named message type flags.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 4226a67..7004b7f 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -355,6 +355,12 @@ struct cmdline_info {
 	void *ioctl_val;
 };
 
+struct named_flag {
+	const char *name;
+	u32 flag;
+	int *wanted;
+};
+
 static struct cmdline_info cmdline_gregs[] = {
 	{ "raw", CMDL_BOOL, &gregs_dump_raw, NULL },
 	{ "hex", CMDL_BOOL, &gregs_dump_hex, NULL },
@@ -520,6 +526,41 @@ static void parse_generic_cmdline(int argc, char **argp,
 	}
 }
 
+static void
+print_flags(const struct named_flag *flags, unsigned int n_flags, u32 value)
+{
+	const char *sep = "";
+
+	while (n_flags) {
+		if (value & flags->flag) {
+			printf("%s%s", sep, flags->name);
+			sep = " ";
+			value &= ~flags->flag;
+		}
+		++flags;
+		--n_flags;
+	}
+
+	/* Print any unrecognised flags in hex */
+	if (value)
+		printf("%s%#x", sep, value);
+}
+
+static u32
+update_flags(const struct named_flag *flags, unsigned int n_flags, u32 value)
+{
+	while (n_flags) {
+		if (*flags->wanted == 0)
+			value &= ~flags->flag;
+		else if (*flags->wanted == 1)
+			value |= flags->flag;
+		++flags;
+		--n_flags;
+	}
+
+	return value;
+}
+
 static int rxflow_str_to_type(const char *str)
 {
 	int flow_type = 0;
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


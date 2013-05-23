From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH] Ethtool: Beautify private flags print
Date: Thu, 23 May 2013 20:55:51 +0300
Message-ID: <1369331751-32543-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: bhutchings@solarflare.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4664 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757799Ab3EWR4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 13:56:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When printing the private flags of the device, align all strings
to have the same length.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
---
 ethtool.c | 26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 8cc10b5..1244c74 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3445,6 +3445,7 @@ static int do_gprivflags(struct cmd_context *ctx)
 	struct ethtool_gstrings *strings;
 	struct ethtool_value flags;
 	unsigned int i;
+	int max_len = 0, cur_len;
 
 	if (ctx->argc != 0)
 		exit_bad_args();
@@ -3472,11 +3473,28 @@ static int do_gprivflags(struct cmd_context *ctx)
 		return 1;
 	}
 
+	/* Find longest string and align all strings accordingly */
+	for (i = 0; i < strings->len; i++) {
+		cur_len = strlen((const char*)strings->data +
+					      i * ETH_GSTRING_LEN);
+		if (cur_len > max_len)
+			max_len = cur_len;
+	}
+
 	printf("Private flags for %s:\n", ctx->devname);
-	for (i = 0; i < strings->len; i++)
-		printf("%s: %s\n",
-		       (const char *)strings->data + i * ETH_GSTRING_LEN,
-		       (flags.data & (1U << i)) ? "on" : "off");
+	for (i = 0; i < strings->len; i++) {
+		int j;
+
+		printf("%s", (const char *)strings->data +
+					   i * ETH_GSTRING_LEN);
+
+		cur_len = strlen((const char*)strings->data +
+					      i * ETH_GSTRING_LEN);
+		for (j = 0; j < max_len - cur_len; j++)
+			printf(" ");
+
+		printf(": %s\n", (flags.data & (1U << i)) ? "on" : "off");
+	}
 
 	return 0;
 }
-- 
1.8.1.227.g44fe835

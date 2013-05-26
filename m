From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH v2] Ethtool: Beautify private flags print
Date: Sun, 26 May 2013 07:55:55 +0300
Message-ID: <1369544155-12279-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: bhutchings@solarflare.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2227 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751925Ab3EZE4R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 May 2013 00:56:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When printing the private flags of the device, align all strings
to have the same length.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
---
Changes from V1:
  - use "%-*s" instead of printing white spaces in for-loop.
---
 ethtool.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/ethtool.c b/ethtool.c
index 8cc10b5..57a6e01 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3445,6 +3445,7 @@ static int do_gprivflags(struct cmd_context *ctx)
 	struct ethtool_gstrings *strings;
 	struct ethtool_value flags;
 	unsigned int i;
+	int max_len = 0, cur_len;
 
 	if (ctx->argc != 0)
 		exit_bad_args();
@@ -3472,9 +3473,18 @@ static int do_gprivflags(struct cmd_context *ctx)
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
 	for (i = 0; i < strings->len; i++)
-		printf("%s: %s\n",
+		printf("%-*s: %s\n",
+		       max_len,
 		       (const char *)strings->data + i * ETH_GSTRING_LEN,
 		       (flags.data & (1U << i)) ? "on" : "off");
 
-- 
1.8.1.227.g44fe835

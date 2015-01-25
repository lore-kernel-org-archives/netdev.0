From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH ethtool 4/5] ethtool: Prettify RX flow hash indirection table print
Date: Sun, 25 Jan 2015 15:51:22 +0200
Message-ID: <1422193883-30504-5-git-send-email-amirv@mellanox.com>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:55361 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753868AbbAYNv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jan 2015 08:51:59 -0500
In-Reply-To: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

When indirection table size is not a multiple of 8, a new line is
missing at the last row of the table.
In addition, make a distinction between the attribute name and its value
by adding an indentation on the beginning of each line which contains
values.

Before the changne:
[user@host]# ./ethtool-3.16 -x enp5s0
RX flow hash indirection table for enp5s0 with 20 RX ring(s):
    0:      0     1     2     3     4     5     6     7
    8:      8     9    10    11    12    13    14    15
   16:      0     1     2     3RSS hash key:
16:d5:5a:31:21:8d:0e:2b:55:ea:ca:70:a8:19:5e:72:2e:c0:f9:0f:9b:6c:94:8f:59:ca:42:d1:c3:58:91:4a:3d:77:a1:e5:ab:8b:6f:68

After:
[user@host]# ./ethtool-3.16+ -x enp5s0
RX flow hash indirection table for enp5s0 with 20 RX ring(s):
    0:      0     1     2     3     4     5     6     7
    8:      8     9    10    11    12    13    14    15
   16:      0     1     2     3
RSS hash key:
    16:d5:5a:31:21:8d:0e:2b:55:ea:ca:70:a8:19:5e:72:2e:c0:f9:0f:9b:6c:94:8f:59:ca:42:d1:c3:58:91:4a:3d:77:a1:e5:ab:8b:6f:68

Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 ethtool.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 8d53a53..c2f4164 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3120,19 +3120,19 @@ static void print_indir_table(struct cmd_context *ctx,
 {
 	u32 i;
 
-	printf("RX flow hash indirection table for %s with %llu RX ring(s):\n",
+	printf("RX flow hash indirection table for %s with %llu RX ring(s):",
 	       ctx->devname, ring_count->data);
 
 	if (!indir_size)
-		printf("Operation not supported\n");
+		printf("\n  Operation not supported");
 
 	for (i = 0; i < indir_size; i++) {
 		if (i % 8 == 0)
-			printf("%5u: ", i);
+			printf("\n%5u: ", i);
 		printf(" %5u", indir[i]);
-		if (i % 8 == 7)
-			fputc('\n', stdout);
 	}
+	fputc('\n', stdout);
+
 }
 
 static int do_grxfhindir(struct cmd_context *ctx,
@@ -3220,7 +3220,7 @@ static int do_grxfh(struct cmd_context *ctx)
 	indir_bytes = rss->indir_size * sizeof(rss->rss_config[0]);
 	hkey = ((char *)rss->rss_config + indir_bytes);
 
-	printf("RSS hash key:\n");
+	printf("RSS hash key:\n    ");
 	if (!rss->key_size)
 		printf("Operation not supported\n");
 
-- 
1.9.3

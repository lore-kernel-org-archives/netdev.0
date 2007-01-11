From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ethtool: fix long statistics name
Date: Thu, 11 Jan 2007 15:36:10 -0800
Message-ID: <20070111153610.36d0f39a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42848 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932158AbXAKXgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 18:36:14 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix handling of statistics where the label is exactly 32 (ETH_GSTRING_LEN)
characters long (observed with chelsio 10G driver). 
Before it would print garbage because of going by end
of string. Don't need to copy string, just use formats properly.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 ethtool.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 6e68009..0a50144 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1989,12 +1989,10 @@ static int do_gstats(int fd, struct ifre
 	/* todo - pretty-print the strings per-driver */
 	fprintf(stdout, "NIC statistics:\n");
 	for (i = 0; i < n_stats; i++) {
-		char s[ETH_GSTRING_LEN];
-
-		strncpy(s, (const char *) &strings->data[i * ETH_GSTRING_LEN],
-			ETH_GSTRING_LEN);
-		fprintf(stdout, "     %s: %llu\n",
-			s, stats->data[i]);
+		fprintf(stdout, "     %.*s: %llu\n",
+			ETH_GSTRING_LEN, 
+			&strings->data[i * ETH_GSTRING_LEN],
+			stats->data[i]);
 	}
 	free(strings);
 	free(stats);
-- 
1.4.1



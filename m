From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] net/rds: using strlcpy instead of strncpy
Date: Thu, 28 Feb 2013 16:28:36 +0800
Message-ID: <512F1534.9020404@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: venkat.x.venkatsubra@oracle.com,
	David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:31211 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474Ab3B1I26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 03:28:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  when src strlen is sizeof(ctr.name) - 1, the dest str is not '\0' end.
  better use strlcpy instead.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 net/rds/stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rds/stats.c b/net/rds/stats.c
index 7be790d..b9ac1df 100644
--- a/net/rds/stats.c
+++ b/net/rds/stats.c
@@ -86,7 +86,7 @@ void rds_stats_info_copy(struct rds_info_iterator *iter,
 
 	for (i = 0; i < nr; i++) {
 		BUG_ON(strlen(names[i]) >= sizeof(ctr.name));
-		strncpy(ctr.name, names[i], sizeof(ctr.name) - 1);
+		strlcpy(ctr.name, names[i], sizeof(ctr.name));
 		ctr.value = values[i];
 
 		rds_info_copy(iter, &ctr, sizeof(ctr));
-- 
1.7.7.6

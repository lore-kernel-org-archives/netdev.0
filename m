From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 15/18] ss: Make unix_state_map local to unix_show()
Date: Fri,  2 Dec 2016 11:39:59 +0100
Message-ID: <20161202104002.17310-16-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:57408 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933964AbcLBKlK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:41:10 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also make it const, since there won't be any write access happening.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index c7818eadf9e75..e82c416b5fa72 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2914,9 +2914,6 @@ outerr:
 	} while (0);
 }
 
-int unix_state_map[] = { SS_CLOSE, SS_SYN_SENT,
-			 SS_ESTABLISHED, SS_CLOSING };
-
 #define MAX_UNIX_REMEMBER (1024*1024/sizeof(struct sockstat))
 
 static void unix_list_drop_first(struct sockstat **list)
@@ -3058,6 +3055,8 @@ static int unix_show(struct filter *f)
 	int  newformat = 0;
 	int  cnt;
 	struct sockstat *list = NULL;
+	const int unix_state_map[] = { SS_CLOSE, SS_SYN_SENT,
+				       SS_ESTABLISHED, SS_CLOSING };
 
 	if (!filter_af_get(f, AF_UNIX))
 		return 0;
-- 
2.10.0

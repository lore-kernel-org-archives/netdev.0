From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 15/18] ss: Make unix_state_map local to unix_show()
Date: Fri, 11 Nov 2016 14:10:11 +0100
Message-ID: <20161111131014.21865-16-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:55531 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756486AbcKKNKv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:10:51 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also make it const, since there won't be any write access happening.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 85fc6096a986f..cf4187310816e 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2727,9 +2727,6 @@ outerr:
 	} while (0);
 }
 
-int unix_state_map[] = { SS_CLOSE, SS_SYN_SENT,
-			 SS_ESTABLISHED, SS_CLOSING };
-
 #define MAX_UNIX_REMEMBER (1024*1024/sizeof(struct sockstat))
 
 static void unix_list_drop_first(struct sockstat **list)
@@ -2869,6 +2866,8 @@ static int unix_show(struct filter *f)
 	int  newformat = 0;
 	int  cnt;
 	struct sockstat *list = NULL;
+	const int unix_state_map[] = { SS_CLOSE, SS_SYN_SENT,
+				       SS_ESTABLISHED, SS_CLOSING };
 
 	if (!filter_af_get(f, AF_UNIX))
 		return 0;
-- 
2.10.0

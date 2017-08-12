From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 35/51] ss: Fix potential memleak in unix_stats_print()
Date: Sat, 12 Aug 2017 14:04:54 +0200
Message-ID: <20170812120510.28750-36-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37293 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752520AbdHLMGN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:06:13 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 2d0e538f3e1cd ("ss: Drop list traversal from unix_stats_print()")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 667b8faad6528..7d84b83c8ad71 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3170,8 +3170,10 @@ static int unix_show(struct filter *f)
 
 		if (name[0]) {
 			u->name = strdup(name);
-			if (!u->name)
+			if (!u->name) {
+				free(u);
 				break;
+			}
 		}
 
 		if (u->rport) {
-- 
2.13.1

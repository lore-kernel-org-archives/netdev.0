From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 4/5] ss: Fix potential memleak in unix_stats_print()
Date: Thu, 17 Aug 2017 19:09:30 +0200
Message-ID: <20170817170931.24435-5-phil@nwl.cc>
References: <20170817170931.24435-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:38089 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753386AbdHQRKd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:10:33 -0400
In-Reply-To: <20170817170931.24435-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 2d0e538f3e1cd ("ss: Drop list traversal from unix_stats_print()")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 07eecfa7a36db..34c6da5443642 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3169,8 +3169,10 @@ static int unix_show(struct filter *f)
 
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

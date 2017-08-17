From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 2/5] nstat: Fix for potential NULL pointer dereference
Date: Thu, 17 Aug 2017 19:09:28 +0200
Message-ID: <20170817170931.24545-3-phil@nwl.cc>
References: <20170817170931.24545-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:41743 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753444AbdHQRNX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:13:23 -0400
In-Reply-To: <20170817170931.24545-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the string at 'p' contains neither space not newline, 'p' will become
NULL. Make sure this isn't the case before dereferencing it.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/nstat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/nstat.c b/misc/nstat.c
index a4dd405d43a93..23e1569d7872b 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -198,7 +198,7 @@ static void load_ugly_table(FILE *fp)
 		off = p - buf;
 		p += 2;
 
-		while (*p) {
+		while (p && *p) {
 			char *next;
 
 			if ((next = strchr(p, ' ')) != NULL)
-- 
2.13.1

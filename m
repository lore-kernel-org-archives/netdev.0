From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 2/5] nstat: Fix for potential NULL pointer dereference
Date: Mon, 21 Aug 2017 12:03:05 +0200
Message-ID: <20170821100308.24854-3-phil@nwl.cc>
References: <20170821100308.24854-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58493 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753065AbdHUKDw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 06:03:52 -0400
In-Reply-To: <20170821100308.24854-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the string at 'p' contains neither space not newline, 'p' will become
NULL. Make sure this isn't the case before dereferencing it.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v2:
- Call abort() if 'p' becomes NULL.
---
 misc/nstat.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/misc/nstat.c b/misc/nstat.c
index a4dd405d43a93..56e9367e99736 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -217,6 +217,8 @@ static void load_ugly_table(FILE *fp)
 			n->next = db;
 			db = n;
 			p = next;
+			if (!p)
+				abort();
 		}
 		n = db;
 		if (fgets(buf, sizeof(buf), fp) == NULL)
-- 
2.13.1

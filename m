From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 3/5] ifstat: Fix memleak in dump_kern_db() for json output
Date: Thu, 17 Aug 2017 19:09:29 +0200
Message-ID: <20170817170931.24435-4-phil@nwl.cc>
References: <20170817170931.24435-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36701 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753637AbdHQRNs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:13:48 -0400
In-Reply-To: <20170817170931.24435-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like this was forgotten when converting to common json output
formatter.

Fixes: fcc16c2287bf8 ("provide common json output formatter")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ifstat.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index 8fa354265a9a1..1be21703bf14c 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -535,8 +535,12 @@ static void dump_kern_db(FILE *fp)
 		else
 			print_one_if(fp, n, n->val);
 	}
-	if (json_output)
-		fprintf(fp, "\n} }\n");
+	if (jw) {
+		jsonw_end_object(jw);
+
+		jsonw_end_object(jw);
+		jsonw_destroy(&jw);
+	}
 }
 
 static void dump_incr_db(FILE *fp)
-- 
2.13.1

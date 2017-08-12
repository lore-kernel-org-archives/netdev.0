From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 25/51] ifstat: Fix memleak in dump_kern_db() for json output
Date: Sat, 12 Aug 2017 14:04:44 +0200
Message-ID: <20170812120510.28750-26-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:57369 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752023AbdHLMGT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:06:19 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
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
index 6c8cfa0bd94f5..ac3eff6b870a9 100644
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

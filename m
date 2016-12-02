From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 12/18] ss: Make slabstat_ids local to get_slabstat()
Date: Fri,  2 Dec 2016 11:39:56 +0100
Message-ID: <20161202104002.17310-13-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:56959 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933964AbcLBKlE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:41:04 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 3662f5f4861c7..c498478421190 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -601,21 +601,19 @@ struct slabstat {
 
 static struct slabstat slabstat;
 
-static const char *slabstat_ids[] = {
-
-	"sock",
-	"tcp_bind_bucket",
-	"tcp_tw_bucket",
-	"tcp_open_request",
-	"skbuff_head_cache",
-};
-
 static int get_slabstat(struct slabstat *s)
 {
 	char buf[256];
 	FILE *fp;
 	int cnt;
 	static int slabstat_valid;
+	static const char * const slabstat_ids[] = {
+		"sock",
+		"tcp_bind_bucket",
+		"tcp_tw_bucket",
+		"tcp_open_request",
+		"skbuff_head_cache",
+	};
 
 	if (slabstat_valid)
 		return 0;
-- 
2.10.0

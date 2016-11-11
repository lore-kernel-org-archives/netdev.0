From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 12/18] ss: Make slabstat_ids local to get_slabstat()
Date: Fri, 11 Nov 2016 14:10:08 +0100
Message-ID: <20161111131014.21865-13-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58515 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756314AbcKKNKi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:10:38 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index d546a00eb2c24..c3a5148e05013 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -580,21 +580,19 @@ struct slabstat {
 
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

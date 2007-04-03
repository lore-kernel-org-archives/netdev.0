From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 1/2] [iputils] Fix asymm messages.
Date: Tue,  3 Apr 2007 14:20:34 -0400
Message-ID: <1175624435275-git-send-email-jheffner@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:58794 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753569AbXDCTSZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 15:18:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should only print the asymm messages in tracepath/6 when you receive a
TTL expired message, because this is the only time when we'd expect the
same number of hops back as our TTL was set to for a symmetric path.
---
 tracepath.c  |   25 ++++++++++++-------------
 tracepath6.c |   25 ++++++++++++-------------
 2 files changed, 24 insertions(+), 26 deletions(-)

diff --git a/tracepath.c b/tracepath.c
index a562d88..d035a1e 100644
--- a/tracepath.c
+++ b/tracepath.c
@@ -163,19 +163,6 @@ restart:
 		}
 	}
 
-	if (rethops>=0) {
-		if (rethops<=64)
-			rethops = 65-rethops;
-		else if (rethops<=128)
-			rethops = 129-rethops;
-		else
-			rethops = 256-rethops;
-		if (sndhops>=0 && rethops != sndhops)
-			printf("asymm %2d ", rethops);
-		else if (sndhops<0 && rethops != ttl)
-			printf("asymm %2d ", rethops);
-	}
-
 	if (rettv) {
 		int diff = (tv.tv_sec-rettv->tv_sec)*1000000+(tv.tv_usec-rettv->tv_usec);
 		printf("%3d.%03dms ", diff/1000, diff%1000);
@@ -204,6 +191,18 @@ restart:
 		if (e->ee_origin == SO_EE_ORIGIN_ICMP &&
 		    e->ee_type == 11 &&
 		    e->ee_code == 0) {
+			if (rethops>=0) {
+				if (rethops<=64)
+					rethops = 65-rethops;
+				else if (rethops<=128)
+					rethops = 129-rethops;
+				else
+					rethops = 256-rethops;
+				if (sndhops>=0 && rethops != sndhops)
+					printf("asymm %2d ", rethops);
+				else if (sndhops<0 && rethops != ttl)
+					printf("asymm %2d ", rethops);
+			}
 			printf("\n");
 			break;
 		}
diff --git a/tracepath6.c b/tracepath6.c
index 6f13a51..a010218 100644
--- a/tracepath6.c
+++ b/tracepath6.c
@@ -176,19 +176,6 @@ restart:
 		}
 	}
 
-	if (rethops>=0) {
-		if (rethops<=64)
-			rethops = 65-rethops;
-		else if (rethops<=128)
-			rethops = 129-rethops;
-		else
-			rethops = 256-rethops;
-		if (sndhops>=0 && rethops != sndhops)
-			printf("asymm %2d ", rethops);
-		else if (sndhops<0 && rethops != ttl)
-			printf("asymm %2d ", rethops);
-	}
-
 	if (rettv) {
 		int diff = (tv.tv_sec-rettv->tv_sec)*1000000+(tv.tv_usec-rettv->tv_usec);
 		printf("%3d.%03dms ", diff/1000, diff%1000);
@@ -220,6 +207,18 @@ restart:
 		    (e->ee_origin == SO_EE_ORIGIN_ICMP6 &&
 		     e->ee_type == 3 &&
 		     e->ee_code == 0)) {
+			if (rethops>=0) {
+				if (rethops<=64)
+					rethops = 65-rethops;
+				else if (rethops<=128)
+					rethops = 129-rethops;
+				else
+					rethops = 256-rethops;
+				if (sndhops>=0 && rethops != sndhops)
+					printf("asymm %2d ", rethops);
+				else if (sndhops<0 && rethops != ttl)
+					printf("asymm %2d ", rethops);
+			}
 			printf("\n");
 			break;
 		}
-- 
1.5.0.2.gc260-dirty


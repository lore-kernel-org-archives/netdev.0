From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 1/6] tracepath: re-use printf return in print_host
Date: Wed,  1 Aug 2012 11:45:23 -0400
Message-ID: <1343835928-21541-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:51057 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084Ab2HAPp3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2012 11:45:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the printf funcs already return the length of chars displayed,
use that value instead of re-calculating the length with strlen.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 tracepath.c  |   11 ++++-------
 tracepath6.c |   11 ++++-------
 2 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/tracepath.c b/tracepath.c
index bcec20d..ca84a69 100644
--- a/tracepath.c
+++ b/tracepath.c
@@ -68,13 +68,10 @@ void data_wait(int fd)
 
 void print_host(const char *a, const char *b, int both)
 {
-	int plen = 0;
-	printf("%s", a);
-	plen = strlen(a);
-	if (both) {
-		printf(" (%s)", b);
-		plen += strlen(b) + 3;
-	}
+	int plen;
+	plen = printf("%s", a);
+	if (both)
+		plen += printf(" (%s)", b);
 	if (plen >= HOST_COLUMN_SIZE)
 		plen = HOST_COLUMN_SIZE - 1;
 	printf("%*s", HOST_COLUMN_SIZE - plen, "");
diff --git a/tracepath6.c b/tracepath6.c
index 0cbe3a1..5c2db8f 100644
--- a/tracepath6.c
+++ b/tracepath6.c
@@ -80,13 +80,10 @@ void data_wait(int fd)
 
 void print_host(const char *a, const char *b, int both)
 {
-	int plen = 0;
-	printf("%s", a);
-	plen = strlen(a);
-	if (both) {
-		printf(" (%s)", b);
-		plen += strlen(b) + 3;
-	}
+	int plen;
+	plen = printf("%s", a);
+	if (both)
+		plen += printf(" (%s)", b);
 	if (plen >= HOST_COLUMN_SIZE)
 		plen = HOST_COLUMN_SIZE - 1;
 	printf("%*s", HOST_COLUMN_SIZE - plen, "");
-- 
1.7.9.7

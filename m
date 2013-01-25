From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH [iputils] 1/6] tracepath: re-use printf return in print_host
Date: Fri, 25 Jan 2013 00:24:10 -0500
Message-ID: <1359091455-25380-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38479 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301Ab3AYFYS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 00:24:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the printf funcs already return the length of chars displayed,
use that value instead of re-calculating the length with strlen.

This also fixes the handling of the strlen return -- it's a size_t,
not an int.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 tracepath.c  | 11 ++++-------
 tracepath6.c | 11 ++++-------
 2 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/tracepath.c b/tracepath.c
index 8a08f1d..f155816 100644
--- a/tracepath.c
+++ b/tracepath.c
@@ -73,13 +73,10 @@ void data_wait(int fd)
 
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
index 126fadf..bee95c3 100644
--- a/tracepath6.c
+++ b/tracepath6.c
@@ -86,13 +86,10 @@ void data_wait(int fd)
 
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
1.8.0.2

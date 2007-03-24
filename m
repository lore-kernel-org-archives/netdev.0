From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 1/2] [iputils] Add length flag to set initial MTU.
Date: Fri, 23 Mar 2007 20:07:21 -0400
Message-ID: <11746948424197-git-send-email-jheffner@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:59387 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992645AbXCXAqr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 20:46:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: John Heffner <jheffner@psc.edu>
---
 tracepath.c  |   10 ++++++++--
 tracepath6.c |   10 ++++++++--
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/tracepath.c b/tracepath.c
index c3f6f74..1f901ba 100644
--- a/tracepath.c
+++ b/tracepath.c
@@ -265,7 +265,7 @@ static void usage(void) __attribute((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: tracepath [-n] <destination>[/<port>]\n");
+	fprintf(stderr, "Usage: tracepath [-n] [-l <len>] <destination>[/<port>]\n");
 	exit(-1);
 }
 
@@ -279,11 +279,17 @@ main(int argc, char **argv)
 	char *p;
 	int ch;
 
-	while ((ch = getopt(argc, argv, "nh?")) != EOF) {
+	while ((ch = getopt(argc, argv, "nh?l:")) != EOF) {
 		switch(ch) {
 		case 'n':	
 			no_resolve = 1;
 			break;
+		case 'l':
+			if ((mtu = atoi(optarg)) <= overhead) {
+				fprintf(stderr, "Error: length must be >= %d\n", overhead);
+				exit(1);
+			}
+			break;
 		default:
 			usage();
 		}
diff --git a/tracepath6.c b/tracepath6.c
index 23d6a8c..d65230d 100644
--- a/tracepath6.c
+++ b/tracepath6.c
@@ -280,7 +280,7 @@ static void usage(void) __attribute((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: tracepath6 [-n] [-b] <destination>[/<port>]\n");
+	fprintf(stderr, "Usage: tracepath6 [-n] [-b] [-l <len>] <destination>[/<port>]\n");
 	exit(-1);
 }
 
@@ -297,7 +297,7 @@ int main(int argc, char **argv)
 	int gai;
 	char pbuf[NI_MAXSERV];
 
-	while ((ch = getopt(argc, argv, "nbh?")) != EOF) {
+	while ((ch = getopt(argc, argv, "nbh?l:")) != EOF) {
 		switch(ch) {
 		case 'n':	
 			no_resolve = 1;
@@ -305,6 +305,12 @@ int main(int argc, char **argv)
 		case 'b':	
 			show_both = 1;
 			break;
+		case 'l':
+			if ((mtu = atoi(optarg)) <= overhead) {
+				fprintf(stderr, "Error: length must be >= %d\n", overhead);
+				exit(1);
+			}
+			break;
 		default:
 			usage();
 		}
-- 
1.5.0.2.gc260-dirty


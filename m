From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH 2/2] arping: Call usage() before limiting capabilities.
Date: Tue, 27 Nov 2012 13:19:35 +0100
Message-ID: <1354018775-4966-2-git-send-email-jsynacek@redhat.com>
References: <1354018775-4966-1-git-send-email-jsynacek@redhat.com>
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63711 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751413Ab2K0MT6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 07:19:58 -0500
In-Reply-To: <1354018775-4966-1-git-send-email-jsynacek@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise, running arping binary without the capabilities set results in printing
warnings with the usage.

Signed-off-by: Jan Synacek <jsynacek@redhat.com>
---
 arping.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/arping.c b/arping.c
index ccb68a0..02e3d9c 100644
--- a/arping.c
+++ b/arping.c
@@ -959,19 +959,6 @@ main(int argc, char **argv)
 	int socket_errno;
 	int ch;
 
-	limit_capabilities();
-
-#ifdef USE_IDN
-	setlocale(LC_ALL, "");
-#endif
-
-	enable_capability_raw();
-
-	s = socket(PF_PACKET, SOCK_DGRAM, 0);
-	socket_errno = errno;
-
-	disable_capability_raw();
-
 	while ((ch = getopt(argc, argv, "h?bfDUAqc:w:s:I:V")) != EOF) {
 		switch(ch) {
 		case 'b':
@@ -1023,6 +1010,19 @@ main(int argc, char **argv)
 
 	target = *argv;
 
+	limit_capabilities();
+
+#ifdef USE_IDN
+	setlocale(LC_ALL, "");
+#endif
+
+	enable_capability_raw();
+
+	s = socket(PF_PACKET, SOCK_DGRAM, 0);
+	socket_errno = errno;
+
+	disable_capability_raw();
+
 	if (device.name && !*device.name)
 		device.name = NULL;
 
-- 
1.7.11.7

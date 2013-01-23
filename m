From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH 1/2] ninfod: Call limit/drop_capabilities() and open_sock() after checking for -h or -v.
Date: Wed, 23 Jan 2013 14:37:44 +0100
Message-ID: <1358948265-20867-2-git-send-email-jsynacek@redhat.com>
References: <1358948265-20867-1-git-send-email-jsynacek@redhat.com>
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6167 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754629Ab3AWNhy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 08:37:54 -0500
In-Reply-To: <1358948265-20867-1-git-send-email-jsynacek@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Synacek <jsynacek@redhat.com>
---
 ninfod/ninfod.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/ninfod/ninfod.c b/ninfod/ninfod.c
index d1b99d9..58b15aa 100644
--- a/ninfod/ninfod.c
+++ b/ninfod/ninfod.c
@@ -637,16 +637,8 @@ int main (int argc, char **argv)
 
 	appname = argv[0];
 
-	limit_capabilities();
-
-	sock = open_sock();
-	if (sock < 0)
-		sock_errno = errno;
-
 	parse_args(argc, argv);
 
-	drop_capabilities();
-
 	if (opt_h || opt_v)
 		print_copying();
 	if (opt_h) {
@@ -654,6 +646,14 @@ int main (int argc, char **argv)
 		exit(1);
 	}
 
+	limit_capabilities();
+
+	sock = open_sock();
+	if (sock < 0)
+		sock_errno = errno;
+
+	drop_capabilities();
+
 	if (sock_errno) {
 		DEBUG(LOG_ERR, "socket: %s\n", strerror(sock_errno));
 		exit(1);
-- 
1.8.1

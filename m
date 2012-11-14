From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH 2/2] ping: Don't free an unintialized value.
Date: Wed, 14 Nov 2012 13:57:16 +0100
Message-ID: <1352897836-17603-3-git-send-email-jsynacek@redhat.com>
References: <1352897836-17603-1-git-send-email-jsynacek@redhat.com>
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49975 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422711Ab2KNM5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2012 07:57:55 -0500
In-Reply-To: <1352897836-17603-1-git-send-email-jsynacek@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 ping.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/ping.c b/ping.c
index fe9ff8a..9de3d08 100644
--- a/ping.c
+++ b/ping.c
@@ -122,7 +122,7 @@ main(int argc, char **argv)
 	u_char *packet;
 	char *target;
 #ifdef USE_IDN
-	char *hnamebuf;
+	char *hnamebuf = NULL;
 #else
 	char hnamebuf[MAX_HOSTNAMELEN];
 #endif
@@ -263,8 +263,10 @@ main(int argc, char **argv)
 #ifdef USE_IDN
 			int rc;
 
-			free(hnamebuf);
-			hnamebuf = NULL;
+			if (hnamebuf) {
+				free(hnamebuf);
+				hnamebuf = NULL;
+			}
 
 			rc = idna_to_ascii_lz(target, &idn, 0);
 			if (rc != IDNA_SUCCESS) {
-- 
1.7.11.7

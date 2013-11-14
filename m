From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [patch iproute2] lib/utils.c: should return correct error message
Date: Thu, 14 Nov 2013 15:00:24 +0800
Message-ID: <1384412424-746-1-git-send-email-liuhangbin@gmail.com>
Cc: Hangbin Liu <liuhangbin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:56169 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab3KNHBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 02:01:11 -0500
Received: by mail-pb0-f44.google.com with SMTP id rp16so1611584pbb.3
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 23:01:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 lib/utils.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index 4e9c719..59221b2 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -487,7 +487,11 @@ int get_addr(inet_prefix *dst, const char *arg, int family)
 		exit(1);
 	}
 	if (get_addr_1(dst, arg, family)) {
-		fprintf(stderr, "Error: an inet address is expected rather than \"%s\".\n", arg);
+		// FIXME: Don't know how to handle AF_UNSPEC and AF_DECnet
+		if (family == AF_INET6)
+			fprintf(stderr, "Error: an inet6 address is expected rather than \"%s\".\n", arg);
+		else
+			fprintf(stderr, "Error: an inet address is expected rather than \"%s\".\n", arg);
 		exit(1);
 	}
 	return 0;
@@ -500,7 +504,11 @@ int get_prefix(inet_prefix *dst, char *arg, int family)
 		exit(1);
 	}
 	if (get_prefix_1(dst, arg, family)) {
-		fprintf(stderr, "Error: an inet prefix is expected rather than \"%s\".\n", arg);
+		// FIXME: Don't know how to handle AF_DECnet
+		if (family == AF_INET6)
+			fprintf(stderr, "Error: an inet6 prefix is expected rather than \"%s\".\n", arg);
+		else
+			fprintf(stderr, "Error: an inet prefix is expected rather than \"%s\".\n", arg);
 		exit(1);
 	}
 	return 0;
-- 
1.8.1.4

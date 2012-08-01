From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 4/6] ping: fix building on older systems
Date: Wed,  1 Aug 2012 11:45:26 -0400
Message-ID: <1343835928-21541-4-git-send-email-vapier@gentoo.org>
References: <1343835928-21541-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:51067 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755472Ab2HAPpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2012 11:45:31 -0400
In-Reply-To: <1343835928-21541-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SO_MARK define is somewhat recent (linux-2.6.25), so check for its
existence before we try to use it.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 ping_common.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/ping_common.c b/ping_common.c
index 287d0e6..6fd252d 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -486,6 +486,7 @@ void setup(int icmp_sock)
 			fprintf(stderr, "Warning: no SO_TIMESTAMP support, falling back to SIOCGSTAMP\n");
 	}
 #endif
+#ifdef SO_MARK
 	if (options & F_MARK) {
 		if (setsockopt(icmp_sock, SOL_SOCKET, SO_MARK,
 				&mark, sizeof(mark)) == -1) {
@@ -499,6 +500,7 @@ void setup(int icmp_sock)
 #endif
 		}
 	}
+#endif
 
 	/* Set some SNDTIMEO to prevent blocking forever
 	 * on sends, when device is too slow or stalls. Just put limit
-- 
1.7.9.7

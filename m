From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] ping: fix building on older systems
Date: Sat, 19 Feb 2011 12:56:37 -0500
Message-ID: <1298138197-27262-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:33864 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754406Ab1BSR4j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Feb 2011 12:56:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SO_MARK define is somewhat recent (linux-2.6.25), so check for its
existence before we try to use it.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 ping_common.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/ping_common.c b/ping_common.c
index 82320b1..b4b26b2 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -475,6 +475,7 @@ void setup(int icmp_sock)
 			fprintf(stderr, "Warning: no SO_TIMESTAMP support, falling back to SIOCGSTAMP\n");
 	}
 #endif
+#ifdef SO_MARK
 	if (options & F_MARK) {
 		if (setsockopt(icmp_sock, SOL_SOCKET, SO_MARK,
 				&mark, sizeof(mark)) == -1) {
@@ -484,6 +485,7 @@ void setup(int icmp_sock)
 			fprintf(stderr, "Warning: Failed to set mark %d\n", mark);
 		}
 	}
+#endif
 
 	/* Set some SNDTIMEO to prevent blocking forever
 	 * on sends, when device is too slow or stalls. Just put limit
-- 
1.7.4.1


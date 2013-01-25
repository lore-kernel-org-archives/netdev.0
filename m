From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH [iputils] 2/6] ping: fix building on older systems
Date: Fri, 25 Jan 2013 00:24:11 -0500
Message-ID: <1359091455-25380-2-git-send-email-vapier@gentoo.org>
References: <1359091455-25380-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38482 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301Ab3AYFYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 00:24:14 -0500
In-Reply-To: <1359091455-25380-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SO_MARK define is somewhat recent (linux-2.6.25), so check for its
existence before we try to use it.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 ping_common.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ping_common.c b/ping_common.c
index 7f82851..8d6b145 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -630,6 +630,7 @@ void setup(int icmp_sock)
 			fprintf(stderr, "Warning: no SO_TIMESTAMP support, falling back to SIOCGSTAMP\n");
 	}
 #endif
+#ifdef SO_MARK
 	if (options & F_MARK) {
 		int ret;
 
@@ -644,6 +645,7 @@ void setup(int icmp_sock)
 			fprintf(stderr, "Warning: Failed to set mark %d\n", mark);
 		}
 	}
+#endif
 
 	/* Set some SNDTIMEO to prevent blocking forever
 	 * on sends, when device is too slow or stalls. Just put limit
-- 
1.8.0.2

From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2] ip, route: fix minor compile warning
Date: Mon, 14 Dec 2015 16:34:29 +0100
Message-ID: <c43f41f31854bb0a27cc6cd6d9e465a28a94ffb9.1450106992.git.daniel@iogearbox.net>
Cc: phil@nwl.cc, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49542 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513AbbLNPec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 10:34:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems like gcc (4.8.3) doesn't catch this false positive, triggering
after 0f7543322c5f ("route: ignore RTAX_HOPLIMIT of value -1"):

  iproute.c: In function 'print_route':
  iproute.c:301:12: warning: 'val' may be used uninitialized in this function [-Wmaybe-uninitialized]
     features &= ~RTAX_FEATURE_ECN;
              ^
  iproute.c:575:10: note: 'val' was declared here
      __u32 val;
            ^
So just shut it up by initializing to 0.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 ip/iproute.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index c42ea0b..867c8da 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -572,7 +572,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			mxlock = *(unsigned*)RTA_DATA(mxrta[RTAX_LOCK]);
 
 		for (i=2; i<= RTAX_MAX; i++) {
-			__u32 val;
+			__u32 val = 0;
 
 			if (mxrta[i] == NULL)
 				continue;
-- 
1.9.3

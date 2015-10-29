From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] lib/utils: improve error messages of get_addr() and get_prefix()
Date: Thu, 29 Oct 2015 17:05:38 +0100
Message-ID: <1446134738-16732-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:43444 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757286AbbJ2QSI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 12:18:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of statically complaining about illegal inet address, use
get_family() to get the address family right.

Based on a patch by Hangbin Liu to print "inet6" for AF_INET6 made more
generic by me.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/utils.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index b7bdb9d..939a44f 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -531,7 +531,8 @@ done:
 int get_addr(inet_prefix *dst, const char *arg, int family)
 {
 	if (get_addr_1(dst, arg, family)) {
-		fprintf(stderr, "Error: an %s address is expected rather than \"%s\".\n", (family == AF_INET6 ? "inet6" : "inet") ,arg);
+		fprintf(stderr, "Error: %s address is expected rather than \"%s\".\n",
+				family_name(family) ,arg);
 		exit(1);
 	}
 	return 0;
@@ -544,7 +545,8 @@ int get_prefix(inet_prefix *dst, char *arg, int family)
 		exit(1);
 	}
 	if (get_prefix_1(dst, arg, family)) {
-		fprintf(stderr, "Error: an %s prefix is expected rather than \"%s\".\n", (family == AF_INET6 ? "inet6" : "inet") ,arg);
+		fprintf(stderr, "Error: %s prefix is expected rather than \"%s\".\n",
+				family_name(family) ,arg);
 		exit(1);
 	}
 	return 0;
-- 
2.1.2

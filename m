From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2] lib/utils: improve error messages of get_addr() and get_prefix()
Date: Thu, 29 Oct 2015 17:20:56 +0100
Message-ID: <1446135656-17555-1-git-send-email-phil@nwl.cc>
References: <1446134738-16732-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:38545 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752268AbbJ2QU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 12:20:59 -0400
In-Reply-To: <1446134738-16732-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of statically complaining about illegal inet address, use
get_family() to get the address family right.

Based on a patch by Hangbin Liu to print "inet6" for AF_INET6 made more
generic by me.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v1:
- Rebased this patch on top of Stephen Hemminger's master branch, v1 did not
  apply cleanly.
---
 lib/utils.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/utils.c b/lib/utils.c
index 107e3f5..939a44f 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -531,7 +531,8 @@ done:
 int get_addr(inet_prefix *dst, const char *arg, int family)
 {
 	if (get_addr_1(dst, arg, family)) {
-		fprintf(stderr, "Error: an inet address is expected rather than \"%s\".\n", arg);
+		fprintf(stderr, "Error: %s address is expected rather than \"%s\".\n",
+				family_name(family) ,arg);
 		exit(1);
 	}
 	return 0;
@@ -544,7 +545,8 @@ int get_prefix(inet_prefix *dst, char *arg, int family)
 		exit(1);
 	}
 	if (get_prefix_1(dst, arg, family)) {
-		fprintf(stderr, "Error: an inet prefix is expected rather than \"%s\".\n", arg);
+		fprintf(stderr, "Error: %s prefix is expected rather than \"%s\".\n",
+				family_name(family) ,arg);
 		exit(1);
 	}
 	return 0;
-- 
2.1.2

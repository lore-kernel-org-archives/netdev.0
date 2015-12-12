From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] route: Fix printing of locked entries
Date: Sat, 12 Dec 2015 14:09:48 +0100
Message-ID: <1449925788-30736-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:43718 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496AbbLLNKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 08:10:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0f7543322c5fd ("route: ignore RTAX_HOPLIMIT of value -1")
accidentally reordered fprintf statements. This patch restores the
original ordering.

Fixes: 0f7543322c5fd ("route: ignore RTAX_HOPLIMIT of value -1")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iproute.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index c42ea0b9ecb8e..4d86a596175f5 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -577,8 +577,6 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			if (mxrta[i] == NULL)
 				continue;
 
-			if (mxlock & (1<<i))
-				fprintf(fp, " lock");
 			if (i != RTAX_CC_ALGO)
 				val = rta_getattr_u32(mxrta[i]);
 
@@ -590,6 +588,9 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			else
 				fprintf(fp, " metric %d", i);
 
+			if (mxlock & (1<<i))
+				fprintf(fp, " lock");
+
 			switch (i) {
 			case RTAX_FEATURES:
 				print_rtax_features(fp, val);
-- 
2.6.4

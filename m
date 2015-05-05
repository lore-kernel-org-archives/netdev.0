From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] iproute2: Fix typo in get_prefix_1()
Date: Tue,  5 May 2015 02:14:16 +0200
Message-ID: <1051c439b96abe2cf554720d5f7b456c48ebd838.1430784770.git.tgraf@suug.ch>
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37420 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbbEEAOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 20:14:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes a typo in get_prefix_1() which broke the prefix default
names { default | any | all }.

The most obvious fallout from this bug was:

	$ ip route add default via 1.1.1.1
	Error: an inet prefix is expected rather than "default".

Fixes: dacc5d4197c1 ("add basic mpls support to iproute")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/utils.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/utils.c b/lib/utils.c
index 428ad8f..29b4f54 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -496,7 +496,7 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family)
 	if (strcmp(arg, "default") == 0 ||
 	    strcmp(arg, "any") == 0 ||
 	    strcmp(arg, "all") == 0) {
-		if ((family == AF_DECnet) || (family = AF_MPLS))
+		if ((family == AF_DECnet) || (family == AF_MPLS))
 			return -1;
 		dst->family = family;
 		dst->bytelen = 0;
-- 
2.3.5

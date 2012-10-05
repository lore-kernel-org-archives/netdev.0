From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] iproute2: inform user when a neighbor is removed
Date: Fri,  5 Oct 2012 10:02:52 +0200
Message-ID: <1349424172-5602-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:41652 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526Ab2JEH5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 03:57:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running 'ip monitor neigh', there is no hint to tell if a neighbor is
updated or deleted.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipneigh.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 93cfba2..56e56b2 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -249,6 +249,8 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			return 0;
 	}
 
+	if (n->nlmsg_type == RTM_DELNEIGH)
+		fprintf(fp, "delete ");
 	if (tb[NDA_DST]) {
 		fprintf(fp, "%s ",
 			format_host(r->ndm_family,
-- 
1.7.12

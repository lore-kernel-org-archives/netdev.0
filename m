From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH] route: fix ICMP secure_redirects
Date: Mon,  7 Nov 2011 13:41:45 -0200
Message-ID: <1320680505-26367-1-git-send-email-fbl@redhat.com>
Cc: David Miller <davem@davemloft.net>, Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30441 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754418Ab1KGPlu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 10:41:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It should accept ICMP redirects from any host and not
just from gateways when secure_redirects is disabled.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 net/ipv4/route.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 155138d..dd6937ec 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1347,7 +1347,8 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 				continue;
 
 			if (rt->dst.error || rt->dst.dev != dev ||
-			    rt->rt_gateway != old_gw) {
+			    (IN_DEV_SEC_REDIRECTS(in_dev) &&
+			    rt->rt_gateway != old_gw)) {
 				ip_rt_put(rt);
 				continue;
 			}
-- 
1.7.6

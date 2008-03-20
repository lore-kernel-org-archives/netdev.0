From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/1 net-2.6.26] [IPV4]: sk parameter is unused in ipv4_dst_blackhole.
Date: Thu, 20 Mar 2008 16:41:38 +0300
Message-ID: <1206020498-31132-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:56831 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754024AbYCTNl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2008 09:41:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just remove it.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/route.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1051326..9ba3413 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2520,7 +2520,7 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 };
 
 
-static int ipv4_dst_blackhole(struct rtable **rp, struct flowi *flp, struct sock *sk)
+static int ipv4_dst_blackhole(struct rtable **rp, struct flowi *flp)
 {
 	struct rtable *ort = *rp;
 	struct rtable *rt = (struct rtable *)
@@ -2580,7 +2580,7 @@ int ip_route_output_flow(struct net *net, struct rtable **rp, struct flowi *flp,
 		err = __xfrm_lookup((struct dst_entry **)rp, flp, sk,
 				    flags ? XFRM_LOOKUP_WAIT : 0);
 		if (err == -EREMOTE)
-			err = ipv4_dst_blackhole(rp, flp, sk);
+			err = ipv4_dst_blackhole(rp, flp);
 
 		return err;
 	}
-- 
1.5.3.rc5


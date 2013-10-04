From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH] ipv4: fix ineffective source address selection
Date: Fri,  4 Oct 2013 17:04:48 +0200
Message-ID: <245895a0777442b56ecea1453be041aa1b31c5a2.1380898983.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36293 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754120Ab3JDPE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 11:04:59 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r94F4wAE018747
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 4 Oct 2013 11:04:58 -0400
Received: from griffin.i.upir.cz (ovpn-113-117.phx2.redhat.com [10.3.113.117])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r94F4vO2002053
	for <netdev@vger.kernel.org>; Fri, 4 Oct 2013 11:04:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sending out multicast messages, the source address in inet->mc_addr is
ignored and rewritten by an autoselected one. This is caused by a typo in
commit 813b3b5db831 ("ipv4: Use caller's on-stack flowi as-is in output
route lookups").

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/ipv4/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 727f436..6011615 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2072,7 +2072,7 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 							      RT_SCOPE_LINK);
 			goto make_route;
 		}
-		if (fl4->saddr) {
+		if (!fl4->saddr) {
 			if (ipv4_is_multicast(fl4->daddr))
 				fl4->saddr = inet_select_addr(dev_out, 0,
 							      fl4->flowi4_scope);
-- 
1.7.6.5

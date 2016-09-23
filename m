From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net v2] ip6_gre: fix flowi6_proto value in ip6gre_xmit_other()
Date: Fri, 23 Sep 2016 15:50:29 -0400
Message-ID: <1474660229-5665-1-git-send-email-lrichard@redhat.com>
Cc: shmulik.ladkani@gmail.com, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39234 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034816AbcIWTub (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 15:50:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit 3be07244b733 ("ip6_gre: fix flowi6_proto value in
xmit path"), set flowi6_proto to IPPROTO_GRE for output route lookup.

Up until now, ip6gre_xmit_other() has set flowi6_proto to a bogus value.
This affected output route lookup for packets sent on an ip6gretap device
in cases where routing was dependent on the value of flowi6_proto.

Since the correct proto is already set in the tunnel flowi6 template via
commit 252f3f5a1189 ("ip6_gre: Set flowi6_proto as IPPROTO_GRE in xmit
path."), simply delete the line setting the incorrect flowi6_proto value.

Suggested-by: Jiri Benc <jbenc@redhat.com>
Fixes: commit c12b395a4664 ("gre: Support GRE over IPv6")
Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
v2: expanded commit description as suggested by Shmulik Ladkani.

 net/ipv6/ip6_gre.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 704274c..edc3daa 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -648,7 +648,6 @@ static int ip6gre_xmit_other(struct sk_buff *skb, struct net_device *dev)
 		encap_limit = t->parms.encap_limit;
 
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
-	fl6.flowi6_proto = skb->protocol;
 
 	err = gre_handle_offloads(skb, !!(t->parms.o_flags & TUNNEL_CSUM));
 	if (err)
-- 
2.5.5

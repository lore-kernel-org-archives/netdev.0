From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net] ip6_gre: fix flowi6_proto value in ip6gre_xmit_other()
Date: Fri, 23 Sep 2016 12:54:59 -0400
Message-ID: <1474649699-31069-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47732 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760693AbcIWQzA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 12:55:00 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2C40744831
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 16:55:00 +0000 (UTC)
Received: from thinkcentre.nc.rr.com (vpn-54-84.rdu2.redhat.com [10.10.54.84])
        by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u8NGsxFd029385
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 12:54:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit 3be07244b733 ("ip6_gre: fix flowi6_proto value in
xmit path"), set flowi6_proto to IPPROTO_GRE for output route lookup.
Since the correct proto is already set in the tunnel flowi6 template via
commit 252f3f5a1189 ("ip6_gre: Set flowi6_proto as IPPROTO_GRE in xmit
path."), simply delete the line setting the incorrect flowi6_proto value.

Suggested-by: Jiri Benc <jbenc@redhat.com>
Fixes: commit c12b395a4664 ("gre: Support GRE over IPv6")
Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
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

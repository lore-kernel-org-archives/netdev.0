From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net-next] gre: use nla_get_be32() to extract flowinfo
Date: Sat, 24 Sep 2016 14:01:04 -0400
Message-ID: <1474740064-13580-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39094 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755304AbcIXSBG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 24 Sep 2016 14:01:06 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5075A66CA5
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 18:01:05 +0000 (UTC)
Received: from thinkcentre.nc.rr.com (vpn-56-79.rdu2.redhat.com [10.10.56.79])
        by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u8OI14Lc003048
        for <netdev@vger.kernel.org>; Sat, 24 Sep 2016 14:01:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eliminate a sparse endianness mismatch warning, use nla_get_be32() to
extract a __be32 value instead of nla_get_u32().

Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 net/ipv6/ip6_gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 397e1ed..4ce74f8 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1239,7 +1239,7 @@ static void ip6gre_netlink_parms(struct nlattr *data[],
 		parms->encap_limit = nla_get_u8(data[IFLA_GRE_ENCAP_LIMIT]);
 
 	if (data[IFLA_GRE_FLOWINFO])
-		parms->flowinfo = nla_get_u32(data[IFLA_GRE_FLOWINFO]);
+		parms->flowinfo = nla_get_be32(data[IFLA_GRE_FLOWINFO]);
 
 	if (data[IFLA_GRE_FLAGS])
 		parms->flags = nla_get_u32(data[IFLA_GRE_FLAGS]);
-- 
2.5.5

From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v4 5/5] net: ipv6: Use compressed IPv6 addresses showing route replace error
Date: Thu,  2 Feb 2017 12:37:12 -0800
Message-ID: <1486067832-16350-6-git-send-email-dsa@cumulusnetworks.com>
References: <1486067832-16350-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36165 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751723AbdBBUhY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 15:37:24 -0500
Received: by mail-pg0-f50.google.com with SMTP id v184so707647pgv.3
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 12:37:24 -0800 (PST)
In-Reply-To: <1486067832-16350-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_print_replace_route_err logs an error if a route replace fails with
IPv6 addresses in the full format. e.g,:

IPv6: IPV6: multipath route replace failed (check consistency of installed routes): 2001:0db8:0200:0000:0000:0000:0000:0000 nexthop 2001:0db8:0001:0000:0000:0000:0000:0016 ifi 0

Change the message to dump the addresses in the compressed format.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v4
- no change from v3

v3
- new patch for v3 of set

 net/ipv6/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d229c17118e5..9689b111d642 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3009,7 +3009,7 @@ static void ip6_print_replace_route_err(struct list_head *rt6_nh_list)
 	struct rt6_nh *nh;
 
 	list_for_each_entry(nh, rt6_nh_list, next) {
-		pr_warn("IPV6: multipath route replace failed (check consistency of installed routes): %pI6 nexthop %pI6 ifi %d\n",
+		pr_warn("IPV6: multipath route replace failed (check consistency of installed routes): %pI6c nexthop %pI6c ifi %d\n",
 		        &nh->r_cfg.fc_dst, &nh->r_cfg.fc_gateway,
 		        nh->r_cfg.fc_ifindex);
 	}
-- 
2.1.4

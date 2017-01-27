From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v3 4/4] net: ipv6: Use compressed IPv6 addresses showing route replace error
Date: Fri, 27 Jan 2017 15:20:58 -0800
Message-ID: <1485559258-4856-5-git-send-email-dsa@cumulusnetworks.com>
References: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:36746 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750748AbdA0XWD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 18:22:03 -0500
Received: by mail-pg0-f54.google.com with SMTP id 3so26077712pgj.3
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 15:21:07 -0800 (PST)
In-Reply-To: <1485559258-4856-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip6_print_replace_route_err logs an error if a route replace fails with
IPv6 addresses in the full format. e.g,:

IPv6: IPV6: multipath route replace failed (check consistency of installed routes): 2001:0db8:0200:0000:0000:0000:0000:0000 nexthop 2001:0db8:0001:0000:0000:0000:0000:0016 ifi 0

Change the message to dump the addresses in the compressed format.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 747f333ae006..463cc0847a3d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2969,7 +2969,7 @@ static void ip6_print_replace_route_err(struct list_head *rt6_nh_list)
 	struct rt6_nh *nh;
 
 	list_for_each_entry(nh, rt6_nh_list, next) {
-		pr_warn("IPV6: multipath route replace failed (check consistency of installed routes): %pI6 nexthop %pI6 ifi %d\n",
+		pr_warn("IPV6: multipath route replace failed (check consistency of installed routes): %pI6c nexthop %pI6c ifi %d\n",
 		        &nh->r_cfg.fc_dst, &nh->r_cfg.fc_gateway,
 		        nh->r_cfg.fc_ifindex);
 	}
-- 
2.1.4

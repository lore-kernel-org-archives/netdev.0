From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] ip route: Add missing space between nexthop and via for mpls multipath routes
Date: Fri, 17 Mar 2017 16:39:14 -0700
Message-ID: <1489793954-10667-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34177 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751087AbdCRAPc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 20:15:32 -0400
Received: by mail-pf0-f170.google.com with SMTP id p189so20661681pfp.1
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 17:14:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPLS multipath routes are missing a space between 'nexthop' and 'via':

$ ip -net ns1 -f mpls ro ls
100
	nexthopvia inet 172.16.2.2  dev virt12
	nexthopvia inet 172.16.3.2  dev br0

Add it.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/iproute.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index a7296dca8b91..7cdf0726feb3 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -655,7 +655,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 					size_t len = RTA_PAYLOAD(tb[RTA_VIA]) - 2;
 					struct rtvia *via = RTA_DATA(tb[RTA_VIA]);
 
-					fprintf(fp, "via %s %s ",
+					fprintf(fp, " via %s %s ",
 						family_name(via->rtvia_family),
 						format_host(via->rtvia_family, len, via->rtvia_addr));
 				}
-- 
2.1.4

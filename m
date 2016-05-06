From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH iproute2] geneve: fix IPv6 remote address reporting
Date: Fri, 6 May 2016 15:28:25 +0100
Message-ID: <572CAA09.302@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:41917 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757850AbcEFO2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 10:28:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we can only configure unicast, we probably want to be able to
display unicast, rather than multicast.

Fixes: 906ac5437ab8 ("geneve: add support for IPv6 link partners")
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
I'm assuming this is what was intended, but tbh I don't know why we
need to check for multicast on the display side at all, rather than
just displaying whatever the kernel gives us.

 ip/iplink_geneve.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
index 84d948f..65af6b3 100644
--- a/ip/iplink_geneve.c
+++ b/ip/iplink_geneve.c
@@ -204,7 +204,7 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 		memcpy(&addr, RTA_DATA(tb[IFLA_GENEVE_REMOTE6]), sizeof(struct in6_addr));
 		if (memcmp(&addr, &in6addr_any, sizeof(addr)) != 0) {
-			if (IN6_IS_ADDR_MULTICAST(&addr))
+			if (!IN6_IS_ADDR_MULTICAST(&addr))
 				fprintf(f, "remote %s ",
 					format_host(AF_INET6, sizeof(struct in6_addr), &addr));
 		}
-- 
2.4.3

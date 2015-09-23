From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH iproute2] route: filter routes by family if it's specified
Date: Wed, 23 Sep 2015 14:43:46 +0300
Message-ID: <1443008626-1105-1-git-send-email-avagin@openvz.org>
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Andrew Vagin <avagin@openvz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:34227 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469AbbIWLnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 07:43:51 -0400
Received: by lahg1 with SMTP id g1so46942862lah.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 04:43:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Vagin <avagin@openvz.org>

Currently when we specify AF_INET6 when it is disabled, we will get
all routes.

For example, we can boot kernel with ipv6.disable=1 and try to get ipv6
routes:
$ ip -6 route show
default via 192.168.122.1 dev eth0  proto static  metric 100
192.168.122.0/24 dev eth0  proto kernel  scope link  src 192.168.122.141  metric 100

Here are ipv4 routes and this is unexpected behaviour.

Signed-off-by: Andrew Vagin <avagin@openvz.org>
---
 ip/iproute.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ip/iproute.c b/ip/iproute.c
index abe4180..da25548 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -145,6 +145,9 @@ static int filter_nlmsg(struct nlmsghdr *n, struct rtattr **tb, int host_len)
 
 	table = rtm_get_table(r, tb);
 
+	if (preferred_family != AF_UNSPEC && r->rtm_family != preferred_family)
+		return 0;
+
 	if (r->rtm_family == AF_INET6 && table != RT_TABLE_MAIN)
 		ip6_multiple_tables = 1;
 
-- 
2.4.3

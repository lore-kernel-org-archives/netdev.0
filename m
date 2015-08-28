From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] netpoll: warn on netpoll_send_udp users who haven't disabled irqs
Date: Fri, 28 Aug 2015 15:44:25 -0700
Message-ID: <1440801865-9626-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36779 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263AbbH1Woh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 18:44:37 -0400
Received: by padhm10 with SMTP id hm10so20086298pad.3
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 15:44:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Make sure we catch future netpoll_send_udp users who use it without
disabling irqs and also as a hint for poll_controller users.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/core/netpoll.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index c126a878c47c..6aa3db8dfc3b 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -380,6 +380,8 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 	static atomic_t ip_ident;
 	struct ipv6hdr *ip6h;
 
+	WARN_ON_ONCE(!irqs_disabled());
+
 	udp_len = len + sizeof(*udph);
 	if (np->ipv6)
 		ip_len = udp_len + sizeof(*ip6h);
-- 
2.4.3

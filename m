From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] tcp: Fix double sizeof in new tcp_metrics code
Date: Wed, 31 Oct 2012 00:03:09 +0200
Message-ID: <1351634589-4861-1-git-send-email-ja@ssi.bg>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:44882 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934889Ab2J3WDe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 18:03:34 -0400
Received: from ja.ssi.bg (localhost.localdomain [127.0.0.1])
	by ja.ssi.bg (8.14.4/8.14.4) with ESMTP id q9UM3a8S004889
	for <netdev@vger.kernel.org>; Wed, 31 Oct 2012 00:03:36 +0200
Received: (from root@localhost)
	by ja.ssi.bg (8.14.4/8.14.4/Submit) id q9UM3Ze5004887
	for netdev@vger.kernel.org; Wed, 31 Oct 2012 00:03:35 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Fix double sizeof when parsing IPv6 address from
user space because it breaks get/del by specific IPv6 address.

	Problem noticed by David Binderman:

https://bugzilla.kernel.org/show_bug.cgi?id=49171

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/tcp_metrics.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 4c752a6..53bc584 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -864,7 +864,7 @@ static int parse_nl_addr(struct genl_info *info, struct inetpeer_addr *addr,
 	}
 	a = info->attrs[TCP_METRICS_ATTR_ADDR_IPV6];
 	if (a) {
-		if (nla_len(a) != sizeof(sizeof(struct in6_addr)))
+		if (nla_len(a) != sizeof(struct in6_addr))
 			return -EINVAL;
 		addr->family = AF_INET6;
 		memcpy(addr->addr.a6, nla_data(a), sizeof(addr->addr.a6));
-- 
1.7.3.4

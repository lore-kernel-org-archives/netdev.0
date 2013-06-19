From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] sit: fix an oops when IFLA_IPTUN_PROTO is not set
Date: Wed, 19 Jun 2013 12:03:13 +0200
Message-ID: <1371636193-4612-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:52748 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933830Ab3FSKDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 06:03:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The use of this attribute has been added in 32b8a8e59c9c (sit: add IPv4 over
IPv4 support). It is optional, by default proto is IPPROTO_IPV6.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/sit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 6b9c1f12..a23b838 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1310,7 +1310,7 @@ static int ipip6_validate(struct nlattr *tb[], struct nlattr *data[])
 {
 	u8 proto;
 
-	if (!data)
+	if (!data || !data[IFLA_IPTUN_PROTO])
 		return 0;
 
 	proto = nla_get_u8(data[IFLA_IPTUN_PROTO]);
-- 
1.8.2.1

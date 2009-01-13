From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH]IPv6:remove duplicate check of optlen when setsockopt with
 IPV6_PKTINFO option
Date: Tue, 13 Jan 2009 15:35:58 +0800
Message-ID: <496C445E.1000707@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63419 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753169AbZAMHgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 02:36:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Actually the condition (optlen == 0) is included in (optlen < sizeof(struct in6_pktinfo)),
so we do not need to check it separately.

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 net/ipv6/ipv6_sockglue.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 40f3246..e6affa7 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -399,9 +399,7 @@ sticky_done:
 	{
 		struct in6_pktinfo pkt;
 
-		if (optlen == 0)
-			goto e_inval;
-		else if (optlen < sizeof(struct in6_pktinfo) || optval == NULL)
+		if (optlen < sizeof(struct in6_pktinfo) || optval == NULL)
 			goto e_inval;
 
 		if (copy_from_user(&pkt, optval, sizeof(struct in6_pktinfo))) {
-- 
1.6.0.3
-- 
Regards
Yang Hongyang

From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] ipv6: Set mcast_hops to IPV6_DEFAULT_MCASTHOPS when -1 was
 given.
Date: Mon, 28 Nov 2011 15:33:34 +0800
Message-ID: <4ED3394E.7050602@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63160 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751153Ab1K1HdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 02:33:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to set np->mcast_hops to it's default value at this moment
otherwise when we use it and found it's value is -1, the logic to
get default hop limit doesn't take multicast into account and will
return wrong hop limit(IPV6_DEFAULT_HOPLIMIT) which is for unicast.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv6/ipv6_sockglue.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index c99e3ee..26cb08c 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -503,7 +503,7 @@ done:
 			goto e_inval;
 		if (val > 255 || val < -1)
 			goto e_inval;
-		np->mcast_hops = val;
+		np->mcast_hops = (val == -1 ? IPV6_DEFAULT_MCASTHOPS : val);
 		retv = 0;
 		break;
 
-- 
1.7.3.2

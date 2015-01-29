From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] ipv4: Don't increase PMTU with Datagram Too Big message.
Date: Thu, 29 Jan 2015 16:09:03 +0800
Message-ID: <1422518943-30637-1-git-send-email-lw@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Li Wei <lw@cn.fujitsu.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:35284 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753649AbbA2IKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 03:10:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 1191 said, "a host MUST not increase its estimate of the Path
MTU in response to the contents of a Datagram Too Big message."

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv4/route.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d58dd0e..52e1f2b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -966,6 +966,9 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
 	if (dst->dev->mtu < mtu)
 		return;
 
+	if (rt->rt_pmtu && rt->rt_pmtu < mtu)
+		return;
+
 	if (mtu < ip_rt_min_pmtu)
 		mtu = ip_rt_min_pmtu;
 
-- 
2.1.0

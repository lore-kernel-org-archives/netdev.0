From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6 1/4] [IPV6] ADDRCONF: Fix route lifetime setting in
 corner case.
Date: Thu, 15 May 2008 18:17:55 +0900 (JST)
Message-ID: <20080515.181755.63646417.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44217 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbYEOJRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 05:17:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because of arithmetic overflow avoidance, the actual lifetime setting
(vs the value given by RA) did not increase monotonically around
0x7fffffff/HZ.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 12bba08..98aa50c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -475,7 +475,7 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 	lifetime = ntohl(rinfo->lifetime);
 	if (lifetime == 0xffffffff) {
 		/* infinity */
-	} else if (lifetime > 0x7fffffff/HZ) {
+	} else if (lifetime > 0x7fffffff/HZ - 1) {
 		/* Avoid arithmetic overflow */
 		lifetime = 0x7fffffff/HZ - 1;
 	}
-- 
1.4.4.4

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [RFC 1/2] [IPV6] ADDRCONF: Preparation for configurable address
 selection policy with ifindex.
Date: Tue, 30 Oct 2007 14:52:37 +0900 (JST)
Message-ID: <20071030.145237.68878443.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:36847 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbXJ3Fw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 01:52:28 -0400
Received: from localhost (localhost [127.0.0.1])
	by yue.st-paulia.net (Postfix) with ESMTP id 15CF333B46
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 14:52:42 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 348bd8d..8b408b7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -877,7 +877,8 @@ static inline int ipv6_saddr_preferred(int type)
 }
 
 /* static matching label */
-static inline int ipv6_saddr_label(const struct in6_addr *addr, int type)
+static inline int ipv6_addr_label(const struct in6_addr *addr, int type,
+				  int ifindex)
 {
  /*
   * 	prefix (longest match)	label
@@ -912,7 +913,8 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 	struct inet6_ifaddr *ifa_result = NULL;
 	int daddr_type = __ipv6_addr_type(daddr);
 	int daddr_scope = __ipv6_addr_src_scope(daddr_type);
-	u32 daddr_label = ipv6_saddr_label(daddr, daddr_type);
+	int daddr_ifindex = daddr_dev ? daddr_dev->ifindex : 0;
+	u32 daddr_label = ipv6_addr_label(daddr, daddr_type, daddr_ifindex);
 	struct net_device *dev;
 
 	memset(&hiscore, 0, sizeof(hiscore));
@@ -1085,11 +1087,15 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 
 			/* Rule 6: Prefer matching label */
 			if (hiscore.rule < 6) {
-				if (ipv6_saddr_label(&ifa_result->addr, hiscore.addr_type) == daddr_label)
+				if (ipv6_addr_label(&ifa_result->addr,
+						    hiscore.addr_type,
+						    ifa_result->idev->dev->ifindex) == daddr_label)
 					hiscore.attrs |= IPV6_SADDR_SCORE_LABEL;
 				hiscore.rule++;
 			}
-			if (ipv6_saddr_label(&ifa->addr, score.addr_type) == daddr_label) {
+			if (ipv6_addr_label(&ifa->addr,
+					    score.addr_type,
+					    ifa->idev->dev->ifindex) == daddr_label) {
 				score.attrs |= IPV6_SADDR_SCORE_LABEL;
 				if (!(hiscore.attrs & IPV6_SADDR_SCORE_LABEL)) {
 					score.rule = 6;
-- 
1.4.4.4


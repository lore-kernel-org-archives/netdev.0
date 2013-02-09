From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] ipv6 mcast: Do not join device multicast for interface-local
 multicasts.
Date: Sat, 09 Feb 2013 23:29:58 +0900
Message-ID: <51165D66.5090200@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:55943 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757574Ab3BIO37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2013 09:29:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC4291 (IPv6 addressing architecture) says that interface-Local scope
spans only a single interface on a node.  We should not join L2 device
multicast list for addresses in interface-local (or smaller) scope.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/mcast.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index e5de4855..3a2849f 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -661,6 +661,10 @@ static void igmp6_group_added(struct ifmcaddr6 *mc)
 	struct net_device *dev = mc->idev->dev;
 	char buf[MAX_ADDR_LEN];
 
+	if (IPV6_ADDR_MC_SCOPE(&mc->mca_addr) <
+	    IPV6_ADDR_SCOPE_LINKLOCAL)
+		return;
+
 	spin_lock_bh(&mc->mca_lock);
 	if (!(mc->mca_flags&MAF_LOADED)) {
 		mc->mca_flags |= MAF_LOADED;
@@ -687,6 +691,10 @@ static void igmp6_group_dropped(struct ifmcaddr6 *mc)
 	struct net_device *dev = mc->idev->dev;
 	char buf[MAX_ADDR_LEN];
 
+	if (IPV6_ADDR_MC_SCOPE(&mc->mca_addr) <
+	    IPV6_ADDR_SCOPE_LINKLOCAL)
+		return;
+
 	spin_lock_bh(&mc->mca_lock);
 	if (mc->mca_flags&MAF_LOADED) {
 		mc->mca_flags &= ~MAF_LOADED;
-- 
1.7.9.5

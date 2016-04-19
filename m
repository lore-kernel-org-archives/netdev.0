From: Peter Heise <mail@pheise.de>
Subject: [PATCH net-next] NLA_BINARY misuse bug in HSR
Date: Tue, 19 Apr 2016 13:34:28 +0200
Message-ID: <20160419113428.GA10532@aircraft-controller>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, julia.lawall@lip6.fr, peter.heise@airbus.com
To: arvid.brodin@alten.se, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pheise.de ([81.88.24.24]:55010 "EHLO ghost.pheise.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753351AbcDSLee (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 07:34:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed .type field from NLA to do proper length checking.
Reported by Daniel Borkmann and Julia Lawall.

Signed-off-by: Peter Heise <peter.heise@airbus.com>
---
 net/hsr/hsr_netlink.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 5425d87..d4d1617 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -24,7 +24,7 @@ static const struct nla_policy hsr_policy[IFLA_HSR_MAX + 1] = {
 	[IFLA_HSR_SLAVE2]		= { .type = NLA_U32 },
 	[IFLA_HSR_MULTICAST_SPEC]	= { .type = NLA_U8 },
 	[IFLA_HSR_VERSION]	= { .type = NLA_U8 },
-	[IFLA_HSR_SUPERVISION_ADDR]	= { .type = NLA_BINARY, .len = ETH_ALEN },
+	[IFLA_HSR_SUPERVISION_ADDR]	= { .len = ETH_ALEN },
 	[IFLA_HSR_SEQ_NR]		= { .type = NLA_U16 },
 };
 
@@ -121,10 +121,9 @@ static struct rtnl_link_ops hsr_link_ops __read_mostly = {
 
 
 /* attribute policy */
-/* NLA_BINARY missing in libnl; use NLA_UNSPEC in userspace instead. */
 static const struct nla_policy hsr_genl_policy[HSR_A_MAX + 1] = {
-	[HSR_A_NODE_ADDR] = { .type = NLA_BINARY, .len = ETH_ALEN },
-	[HSR_A_NODE_ADDR_B] = { .type = NLA_BINARY, .len = ETH_ALEN },
+	[HSR_A_NODE_ADDR] = { .len = ETH_ALEN },
+	[HSR_A_NODE_ADDR_B] = { .len = ETH_ALEN },
 	[HSR_A_IFINDEX] = { .type = NLA_U32 },
 	[HSR_A_IF1_AGE] = { .type = NLA_U32 },
 	[HSR_A_IF2_AGE] = { .type = NLA_U32 },
-- 
2.5.0

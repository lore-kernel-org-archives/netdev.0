From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.25 2/4] net/core - Convert IP4 address class macros
	to inline functions
Date: Wed, 14 Nov 2007 07:53:28 -0800
Message-ID: <1195055608.5163.180.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@coreworks.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1477 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756477AbXKNPx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 10:53:28 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change LOOPBACK MULTICAST LOCAL_MCAST BADCLASS and ZERONET
macros to inline functions is_ip4_[type](__be32 addr)
Adds some type safety and maybe some readability

No change in compiled image size

Signed-off-by: Joe Perches <joe@perches.com>

---

 net/core/netpoll.c |    2 +-
 net/core/pktgen.c  |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index c499b5c..bf9b4db 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -418,7 +418,7 @@ static void arp_reply(struct sk_buff *skb)
 	memcpy(&tip, arp_ptr, 4);
 
 	/* Should we ignore arp? */
-	if (tip != htonl(np->local_ip) || LOOPBACK(tip) || MULTICAST(tip))
+	if (tip != htonl(np->local_ip) || is_ip4_loopback(tip) || is_ip4_multicast(tip))
 		return;
 
 	size = sizeof(struct arphdr) + 2 * (skb->dev->addr_len + 4);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index de33f36..0d5ef00 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2358,9 +2358,9 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 					t = random32() % (imx - imn) + imn;
 					s = htonl(t);
 
-					while (LOOPBACK(s) || MULTICAST(s)
-					       || BADCLASS(s) || ZERONET(s)
-					       || LOCAL_MCAST(s)) {
+					while (is_ip4_loopback(s) || is_ip4_multicast(s)
+					       || is_ip4_badclass(s) || is_ip4_zeronet(s)
+					       || is_ip4_local_multicast(s)) {
 						t = random32() % (imx - imn) + imn;
 						s = htonl(t);
 					}



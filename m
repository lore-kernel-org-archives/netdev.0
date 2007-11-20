From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.25 4/4] net/netfilter - Convert IP4 address class
	macros to inline functions
Date: Mon, 19 Nov 2007 22:46:14 -0800
Message-ID: <1195541174.4675.99.camel@localhost>
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
Received: from DSL022.labridge.com ([206.117.136.22]:2526 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756712AbXKTGqO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 01:46:14 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change LOOPBACK MULTICAST LOCAL_MCAST BADCLASS and ZERONET
macros to inline functions is_ip4_[type](__be32 addr)

Adds some type safety and arguably some readability

No change in compiled image size

Signed-off-by: Joe Perches <joe@perches.com>

---

 net/netfilter/xt_pkttype.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_pkttype.c b/net/netfilter/xt_pkttype.c
index a52925f..18c54ce 100644
--- a/net/netfilter/xt_pkttype.c
+++ b/net/netfilter/xt_pkttype.c
@@ -34,7 +34,7 @@ static bool match(const struct sk_buff *skb,
 	const struct xt_pkttype_info *info = matchinfo;
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
-		type = MULTICAST(ip_hdr(skb)->daddr)
+		type = ipv4_is_multicast(ip_hdr(skb)->daddr)
 			? PACKET_MULTICAST
 			: PACKET_BROADCAST;
 	else



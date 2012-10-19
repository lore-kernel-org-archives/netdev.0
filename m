From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] pktgen: Use ipv6_addr_any
Date: Thu, 18 Oct 2012 20:55:31 -0700
Message-ID: <408090aa33c0ebcd8d02ce1d14b3dca590fbae62.1350618840.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the standard test for a non-zero ipv6 address.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/pktgen.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d1dc14c..1d1c216 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2427,11 +2427,7 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 		}
 	} else {		/* IPV6 * */
 
-		if (pkt_dev->min_in6_daddr.s6_addr32[0] == 0 &&
-		    pkt_dev->min_in6_daddr.s6_addr32[1] == 0 &&
-		    pkt_dev->min_in6_daddr.s6_addr32[2] == 0 &&
-		    pkt_dev->min_in6_daddr.s6_addr32[3] == 0) ;
-		else {
+		if (!ipv6_addr_any(&pkt_dev->min_in6_daddr)) {
 			int i;
 
 			/* Only random destinations yet */
-- 
1.8.0.rc2.dirty

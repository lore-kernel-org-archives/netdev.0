From: Joe Perches <joe@perches.com>
Subject: [PATCH 6/7] pktgen: Use ether_addr_copy
Date: Mon, 20 Jan 2014 09:52:19 -0800
Message-ID: <66814111bdb4c9db5455b2201a8b9993fb179aea.1390239869.git.joe@perches.com>
References: <cover.1390239869.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1390239869.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use ether_addr_copy instead of memcpy(a, b, ETH_ALEN) to
save some cycles on arm and powerpc.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/pktgen.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index fa3e128..fdac61c 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1440,7 +1440,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		if (!mac_pton(valstr, pkt_dev->dst_mac))
 			return -EINVAL;
 		/* Set up Dest MAC */
-		memcpy(&pkt_dev->hh[0], pkt_dev->dst_mac, ETH_ALEN);
+		ether_addr_copy(&pkt_dev->hh[0], pkt_dev->dst_mac);
 
 		sprintf(pg_result, "OK: dstmac %pM", pkt_dev->dst_mac);
 		return count;
@@ -1457,7 +1457,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		if (!mac_pton(valstr, pkt_dev->src_mac))
 			return -EINVAL;
 		/* Set up Src MAC */
-		memcpy(&pkt_dev->hh[6], pkt_dev->src_mac, ETH_ALEN);
+		ether_addr_copy(&pkt_dev->hh[6], pkt_dev->src_mac);
 
 		sprintf(pg_result, "OK: srcmac %pM", pkt_dev->src_mac);
 		return count;
@@ -2060,10 +2060,10 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 	/* Default to the interface's mac if not explicitly set. */
 
 	if (is_zero_ether_addr(pkt_dev->src_mac))
-		memcpy(&(pkt_dev->hh[6]), pkt_dev->odev->dev_addr, ETH_ALEN);
+		ether_addr_copy(&(pkt_dev->hh[6]), pkt_dev->odev->dev_addr);
 
 	/* Set up Dest MAC */
-	memcpy(&(pkt_dev->hh[0]), pkt_dev->dst_mac, ETH_ALEN);
+	ether_addr_copy(&(pkt_dev->hh[0]), pkt_dev->dst_mac);
 
 	if (pkt_dev->flags & F_IPV6) {
 		int i, set = 0, err = 1;
-- 
1.8.1.2.459.gbcd45b4.dirty

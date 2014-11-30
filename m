From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH] ioc3: fix incorrect use of htons/ntohs
Date: Sun, 30 Nov 2014 11:40:54 +0100
Message-ID: <1417344054-4374-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: ralf@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The protocol type in the ip header struct is a single byte variable. So there
is no need to swap bytes depending on host endianness.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---

Please note that I could not test this, since I dont have access to the
concerning hardware.

 drivers/net/ethernet/sgi/ioc3-eth.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index 7a254da..0bb303d 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -540,8 +540,7 @@ static void ioc3_tcpudp_checksum(struct sk_buff *skb, uint32_t hwsum, int len)
 
 	/* Same as tx - compute csum of pseudo header  */
 	csum = hwsum +
-	       (ih->tot_len - (ih->ihl << 2)) +
-	       htons((uint16_t)ih->protocol) +
+	       (ih->tot_len - (ih->ihl << 2)) + ih->protocol +
 	       (ih->saddr >> 16) + (ih->saddr & 0xffff) +
 	       (ih->daddr >> 16) + (ih->daddr & 0xffff);
 
@@ -1417,7 +1416,7 @@ static int ioc3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		const struct iphdr *ih = ip_hdr(skb);
-		const int proto = ntohs(ih->protocol);
+		const int proto = ih->protocol;
 		unsigned int csoff;
 		uint32_t csum, ehsum;
 		uint16_t *eh;
-- 
1.9.1

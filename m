From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] sungem: remove superfluous variable
Date: Wed, 20 Feb 2008 11:09:27 -0800
Message-ID: <1203534567.7181.200.camel@localhost>
References: <1203507467.17534.34.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1279 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1760362AbYBTTKs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 14:10:48 -0500
In-Reply-To: <1203507467.17534.34.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-02-20 at 12:37 +0100, Johannes Berg wrote:
> There's no need to have two variables called 'i' when one
> suffices.

Additional minor cleanups: tabs and style

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 9721279..8d52d20 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1817,24 +1817,22 @@ static void gem_init_dma(struct gem *gp)
 /* Must be invoked under gp->lock and gp->tx_lock. */
 static u32 gem_setup_multicast(struct gem *gp)
 {
-	u32 rxcfg = 0;
+	u32 rxcfg;
 	int i;
 
 	if ((gp->dev->flags & IFF_ALLMULTI) ||
 	    (gp->dev->mc_count > 256)) {
-	    	for (i=0; i<16; i++)
+		for (i = 0; i < 16; i++)
 			writel(0xffff, gp->regs + MAC_HASH0 + (i << 2));
-		rxcfg |= MAC_RXCFG_HFE;
+		rxcfg = MAC_RXCFG_HFE;
 	} else if (gp->dev->flags & IFF_PROMISC) {
-		rxcfg |= MAC_RXCFG_PROM;
+		rxcfg = MAC_RXCFG_PROM;
 	} else {
 		u16 hash_table[16];
 		u32 crc;
 		struct dev_mc_list *dmi = gp->dev->mc_list;
-		int i;
 
-		for (i = 0; i < 16; i++)
-			hash_table[i] = 0;
+		memset(hash_table, 0, sizeof(hash_table));
 
 		for (i = 0; i < gp->dev->mc_count; i++) {
 			char *addrs = dmi->dmi_addr;
@@ -1844,13 +1842,13 @@ static u32 gem_setup_multicast(struct gem *gp)
 			if (!(*addrs & 1))
 				continue;
 
- 			crc = ether_crc_le(6, addrs);
+			crc = ether_crc_le(6, addrs);
 			crc >>= 24;
 			hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
 		}
-	    	for (i=0; i<16; i++)
+		for (i = 0; i < ARRAY_SIZE(hash_table); i++)
 			writel(hash_table[i], gp->regs + MAC_HASH0 + (i << 2));
-		rxcfg |= MAC_RXCFG_HFE;
+		rxcfg = MAC_RXCFG_HFE;
 	}
 
 	return rxcfg;



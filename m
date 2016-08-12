From: Jiri Kosina <jikos@kernel.org>
Subject: [PATCH net-next] net: fix up a few missing hashtable.h conflict
 resolutions
Date: Fri, 12 Aug 2016 16:34:49 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608121632400.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jkosina@suse.cz>

There are a couple of leftover symbol conflicts caused by hashtable.h 
being included by netdevice.h; those were not caught as build failure 
(they're "only" a warning, but in fact real bugs). Fix those up.

Fixes: e87a8f24c ("net: resolve symbol conflicts with generic hashtable.h")
Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 drivers/net/ethernet/dec/tulip/de4x5.c    | 4 ++--
 drivers/net/ethernet/dec/tulip/de4x5.h    | 4 ++--
 drivers/net/ethernet/freescale/fec_main.c | 6 +++---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index f0e9e2e..6620fc8 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -1966,7 +1966,7 @@ SetMulticastFilter(struct net_device *dev)
     } else if (lp->setup_f == HASH_PERF) {   /* Hash Filtering */
 	netdev_for_each_mc_addr(ha, dev) {
 		crc = ether_crc_le(ETH_ALEN, ha->addr);
-		hashcode = crc & HASH_BITS;  /* hashcode is 9 LSb of CRC */
+		hashcode = crc & DE4X5_HASH_BITS;  /* hashcode is 9 LSb of CRC */
 
 		byte = hashcode >> 3;        /* bit[3-8] -> byte in filter */
 		bit = 1 << (hashcode & 0x07);/* bit[0-2] -> bit in byte */
@@ -5043,7 +5043,7 @@ build_setup_frame(struct net_device *dev, int mode)
 	    *(pa + i) = dev->dev_addr[i];                 /* Host address */
 	    if (i & 0x01) pa += 2;
 	}
-	*(lp->setup_frame + (HASH_TABLE_LEN >> 3) - 3) = 0x80;
+	*(lp->setup_frame + (DE4X5_HASH_TABLE_LEN >> 3) - 3) = 0x80;
     } else {
 	for (i=0; i<ETH_ALEN; i++) { /* Host address */
 	    *(pa + (i&1)) = dev->dev_addr[i];
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.h b/drivers/net/ethernet/dec/tulip/de4x5.h
index ec756eb..1bfdc9b 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.h
+++ b/drivers/net/ethernet/dec/tulip/de4x5.h
@@ -860,8 +860,8 @@
 #define PCI  0
 #define EISA 1
 
-#define HASH_TABLE_LEN   512       /* Bits */
-#define HASH_BITS        0x01ff    /* 9 LS bits */
+#define DE4X5_HASH_TABLE_LEN   512       /* Bits */
+#define DE4X5_HASH_BITS        0x01ff    /* 9 LS bits */
 
 #define SETUP_FRAME_LEN  192       /* Bytes */
 #define IMPERF_PA_OFFSET 156       /* Bytes */
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 01f7e81..fb5c638 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2887,7 +2887,7 @@ fec_enet_close(struct net_device *ndev)
  * this kind of feature?).
  */
 
-#define HASH_BITS	6		/* #bits in hash */
+#define FEC_HASH_BITS	6		/* #bits in hash */
 #define CRC32_POLY	0xEDB88320
 
 static void set_multicast_list(struct net_device *ndev)
@@ -2935,10 +2935,10 @@ static void set_multicast_list(struct net_device *ndev)
 			}
 		}
 
-		/* only upper 6 bits (HASH_BITS) are used
+		/* only upper 6 bits (FEC_HASH_BITS) are used
 		 * which point to specific bit in he hash registers
 		 */
-		hash = (crc >> (32 - HASH_BITS)) & 0x3f;
+		hash = (crc >> (32 - FEC_HASH_BITS)) & 0x3f;
 
 		if (hash > 31) {
 			tmp = readl(fep->hwp + FEC_GRP_HASH_TABLE_HIGH);

-- 
Jiri Kosina
SUSE Labs

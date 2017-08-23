From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 1/3] net: define the TSO header size in net/tso.h
Date: Wed, 23 Aug 2017 09:46:54 +0200
Message-ID: <20170823074656.14595-2-antoine.tenart@free-electrons.com>
References: <20170823074656.14595-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:55981 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753415AbdHWHrM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 03:47:12 -0400
In-Reply-To: <20170823074656.14595-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TSO header size was defined in many drivers. Factorize the code and
define its size in net/tso.h.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h | 1 -
 drivers/net/ethernet/freescale/fec_main.c          | 1 -
 drivers/net/ethernet/marvell/mv643xx_eth.c         | 2 --
 drivers/net/ethernet/marvell/mvneta.c              | 3 ---
 include/net/tso.h                                  | 2 ++
 5 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
index 57858522c33c..67d1a3230773 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -277,7 +277,6 @@ struct snd_queue {
 	u16		xdp_free_cnt;
 	bool		is_xdp;
 
-#define	TSO_HEADER_SIZE	128
 	/* For TSO segment's header */
 	char		*tso_hdrs;
 	dma_addr_t	tso_hdrs_phys;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index df09b254553d..56f56d6ada9c 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -226,7 +226,6 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
 
 #define COPYBREAK_DEFAULT	256
 
-#define TSO_HEADER_SIZE		128
 /* Max number of allowed TCP segments for software TSO */
 #define FEC_MAX_TSO_SEGS	100
 #define FEC_MAX_SKB_DESCS	(FEC_MAX_TSO_SEGS * 2 + MAX_SKB_FRAGS)
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 9c94ea9b2b80..fb2d533ae4ef 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -183,8 +183,6 @@ static char mv643xx_eth_driver_version[] = "1.4";
 #define DEFAULT_TX_QUEUE_SIZE	512
 #define SKB_DMA_REALIGN		((PAGE_SIZE - NET_SKB_PAD) % SMP_CACHE_BYTES)
 
-#define TSO_HEADER_SIZE		128
-
 /* Max number of allowed TCP segments for software TSO */
 #define MV643XX_MAX_TSO_SEGS 100
 #define MV643XX_MAX_SKB_DESCS (MV643XX_MAX_TSO_SEGS * 2 + MAX_SKB_FRAGS)
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 0aab74c2a209..35ff1ecfcff0 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -281,9 +281,6 @@
  */
 #define MVNETA_RSS_LU_TABLE_SIZE	1
 
-/* TSO header size */
-#define TSO_HEADER_SIZE 128
-
 /* Max number of Rx descriptors */
 #define MVNETA_MAX_RXD 128
 
diff --git a/include/net/tso.h b/include/net/tso.h
index b7be852bfe9d..9a56c39e6d0a 100644
--- a/include/net/tso.h
+++ b/include/net/tso.h
@@ -3,6 +3,8 @@
 
 #include <net/ip.h>
 
+#define TSO_HEADER_SIZE		128
+
 struct tso_t {
 	int next_frag_idx;
 	void *data;
-- 
2.13.5

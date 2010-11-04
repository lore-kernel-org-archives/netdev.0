From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] drivers/net: normalize TX_TIMEOUT
Date: Thu, 04 Nov 2010 09:49:35 +0100
Message-ID: <1288860575.2659.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36342 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753254Ab0KDIts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 04:49:48 -0400
Received: by wwb13 with SMTP id 13so385011wwb.1
        for <netdev@vger.kernel.org>; Thu, 04 Nov 2010 01:49:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some network drivers use old TX_TIMEOUT definitions, assuming HZ=100 of
old kernels.

Convert these definitions to include HZ, since HZ can be 1000 these
days.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/3c507.c             |    2 +-
 drivers/net/3c515.c             |    2 +-
 drivers/net/82596.c             |    2 +-
 drivers/net/arm/w90p910_ether.c |    2 +-
 drivers/net/at1700.c            |    2 +-
 drivers/net/atarilance.c        |    2 +-
 drivers/net/eepro.c             |    2 +-
 drivers/net/lance.c             |    2 +-
 drivers/net/lib82596.c          |    2 +-
 drivers/net/znet.c              |    2 +-
 10 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index ea9b7a0..475a66d 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -201,7 +201,7 @@ struct net_local {
 #define RX_BUF_SIZE 	(1518+14+18)	/* packet+header+RBD */
 #define RX_BUF_END		(dev->mem_end - dev->mem_start)
 
-#define TX_TIMEOUT 5
+#define TX_TIMEOUT (HZ/20)
 
 /*
   That's it: only 86 bytes to set up the beast, including every extra
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index cdf7226..376b936 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -98,7 +98,7 @@ static int rx_nocopy, rx_copy, queued_packet;
 #define WAIT_TX_AVAIL 200
 
 /* Operational parameter that usually are not changed. */
-#define TX_TIMEOUT  40		/* Time in jiffies before concluding Tx hung */
+#define TX_TIMEOUT  ((4*HZ)/10)	/* Time in jiffies before concluding Tx hung */
 
 /* The size here is somewhat misleading: the Corkscrew also uses the ISA
    aliased registers at <base>+0x400.
diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index e2c9c5b..be1f197 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -191,7 +191,7 @@ enum commands {
 #define	 RX_SUSPEND	0x0030
 #define	 RX_ABORT	0x0040
 
-#define TX_TIMEOUT	5
+#define TX_TIMEOUT	(HZ/20)
 
 
 struct i596_reg {
diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/arm/w90p910_ether.c
index 4545d5a..bfea499 100644
--- a/drivers/net/arm/w90p910_ether.c
+++ b/drivers/net/arm/w90p910_ether.c
@@ -117,7 +117,7 @@
 #define TX_DESC_SIZE		10
 #define MAX_RBUFF_SZ		0x600
 #define MAX_TBUFF_SZ		0x600
-#define TX_TIMEOUT		50
+#define TX_TIMEOUT		(HZ/2)
 #define DELAY			1000
 #define CAM0			0x0
 
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index 8987689..871b163 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -150,7 +150,7 @@ struct net_local {
 #define PORT_OFFSET(o) (o)
 
 
-#define TX_TIMEOUT		10
+#define TX_TIMEOUT		(HZ/10)
 
 
 /* Index to functions, as function prototypes. */
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index 8cb27cb..ce0091e 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -116,7 +116,7 @@ MODULE_LICENSE("GPL");
 #define RX_RING_LEN_BITS		(RX_LOG_RING_SIZE << 5)
 #define	RX_RING_MOD_MASK		(RX_RING_SIZE - 1)
 
-#define TX_TIMEOUT	20
+#define TX_TIMEOUT	(HZ/5)
 
 /* The LANCE Rx and Tx ring descriptors. */
 struct lance_rx_head {
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 7c82631..9e19fbc 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -302,7 +302,7 @@ struct eepro_local {
 #define ee_id_eepro10p0 0x10   /* ID for eepro/10+ */
 #define ee_id_eepro10p1 0x31
 
-#define TX_TIMEOUT 40
+#define TX_TIMEOUT ((4*HZ)/10)
 
 /* Index to functions, as function prototypes. */
 
diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index f06296b..02336ed 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -207,7 +207,7 @@ tx_full and tbusy flags.
 #define LANCE_BUS_IF 0x16
 #define LANCE_TOTAL_SIZE 0x18
 
-#define TX_TIMEOUT	20
+#define TX_TIMEOUT	(HZ/5)
 
 /* The LANCE Rx and Tx ring descriptors. */
 struct lance_rx_head {
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index c27f429..9e04289 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -161,7 +161,7 @@ enum commands {
 #define	 RX_SUSPEND	0x0030
 #define	 RX_ABORT	0x0040
 
-#define TX_TIMEOUT	5
+#define TX_TIMEOUT	(HZ/20)
 
 
 struct i596_reg {
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index c3a3292..ae07b3d 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -124,7 +124,7 @@ MODULE_LICENSE("GPL");
 #define TX_BUF_SIZE 8192
 #define DMA_BUF_SIZE (RX_BUF_SIZE + 16)	/* 8k + 16 bytes for trailers */
 
-#define TX_TIMEOUT	10
+#define TX_TIMEOUT	(HZ/10)
 
 struct znet_private {
 	int rx_dma, tx_dma;



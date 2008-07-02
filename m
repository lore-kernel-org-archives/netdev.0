From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: WAN: Remove dead code from PC300 driver, part #2
Date: Wed, 02 Jul 2008 21:16:21 +0200
Message-ID: <m3myl03xmi.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:49266 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752857AbYGBTX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 15:23:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For review only, the actual patch will be made available in git.

WAN: Remove dead code from PC300 driver, part #2

diff --git a/drivers/net/wan/pc300.h b/drivers/net/wan/pc300.h
index cd24ea5..cee799d 100644
--- a/drivers/net/wan/pc300.h
+++ b/drivers/net/wan/pc300.h
@@ -103,13 +103,9 @@
 #include "hd64572.h"
 #include "pc300-falc-lh.h"
 
-#ifndef CY_TYPES
-#define CY_TYPES
-typedef	__u64	ucdouble;	/* 64 bits, unsigned */
 typedef	__u32	uclong;		/* 32 bits, unsigned */
 typedef	__u16	ucshort;	/* 16 bits, unsigned */
 typedef	__u8	ucchar;		/* 8 bits, unsigned */
-#endif /* CY_TYPES */
 
 #define PC300_PROTO_MLPPP 1
 
@@ -345,7 +341,6 @@ typedef struct pc300chconf {
 	raw_hdlc_proto		proto_settings;	/* Encoding, parity (CRC) */
 	uclong media;		/* HW media (RS232, V.35, etc.) */
 	uclong proto;		/* Protocol (PPP, X.25, etc.) */
-	ucchar monitor;		/* Monitor mode (0 = off, !0 = on) */
 
 	/* TE-specific parameters */
 	ucchar lcode;		/* Line Code (AMI, B8ZS, etc.) */
@@ -440,9 +435,6 @@ enum pc300_loopback_cmds {
 #define	PC300_DEF_MTU		1600
 
 /* Function Prototypes */
-void tx_dma_start(pc300_t *, int);
 int cpc_open(struct net_device *dev);
-int cpc_set_media(hdlc_device *, int);
 
 #endif	/* _PC300_H */
-
diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 3226a74..65c40cd 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -1805,11 +1805,7 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 	int i;
 #endif
 
-	if (chan->conf.monitor) {
-		/* In monitor mode no Tx is done: ignore packet */
-		dev_kfree_skb(skb);
-		return 0;
-	} else if (!netif_carrier_ok(dev)) {
+	if (!netif_carrier_ok(dev)) {
 		/* DCD must be OFF: drop packet */
 		dev_kfree_skb(skb);
 		dev->stats.tx_errors++;


-- 
Krzysztof Halasa

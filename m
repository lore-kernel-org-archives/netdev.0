From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/3] drivers/net/tlan: Remove TRUE/FALSE defines, use bool
Date: Tue, 12 Jan 2010 22:59:13 -0800
Message-ID: <5effdf5b333df0f28b6426082da278936fa480d4.1263365754.git.joe@perches.com>
References: <cover.1263365754.git.joe@perches.com>
Cc: Samuel Chessman <chessman@tux.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1082 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754989Ab0AMG7R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2010 01:59:17 -0500
In-Reply-To: <cover.1263365754.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tlan.c |   28 ++++++++++++++--------------
 drivers/net/tlan.h |    3 ---
 2 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index fabaeff..bbcac3b 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -338,7 +338,7 @@ static int	TLan_PhyInternalService( struct net_device * );
 static int	TLan_PhyDp83840aCheck( struct net_device * );
 */
 
-static int	TLan_MiiReadReg( struct net_device *, u16, u16, u16 * );
+static bool	TLan_MiiReadReg( struct net_device *, u16, u16, u16 * );
 static void	TLan_MiiSendData( u16, u32, unsigned );
 static void	TLan_MiiSync( u16 );
 static void	TLan_MiiWriteReg( struct net_device *, u16, u16, u16 );
@@ -2204,7 +2204,7 @@ TLan_ResetAdapter( struct net_device *dev )
 	u32		data;
 	u8		data8;
 
-	priv->tlanFullDuplex = FALSE;
+	priv->tlanFullDuplex = false;
 	priv->phyOnline=0;
 	netif_carrier_off(dev);
 
@@ -2259,7 +2259,7 @@ TLan_ResetAdapter( struct net_device *dev )
 			TLan_DioWrite8( dev->base_addr, TLAN_ACOMMIT, 0x0a );
 		} else if ( priv->duplex == TLAN_DUPLEX_FULL ) {
 			TLan_DioWrite8( dev->base_addr, TLAN_ACOMMIT, 0x00 );
-			priv->tlanFullDuplex = TRUE;
+			priv->tlanFullDuplex = true;
 		} else {
 			TLan_DioWrite8( dev->base_addr, TLAN_ACOMMIT, 0x08 );
 		}
@@ -2651,14 +2651,14 @@ static void TLan_PhyStartLink( struct net_device *dev )
 			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, 0x0000);
 		} else if ( priv->speed == TLAN_SPEED_10 &&
 			    priv->duplex == TLAN_DUPLEX_FULL) {
-			priv->tlanFullDuplex = TRUE;
+			priv->tlanFullDuplex = true;
 			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, 0x0100);
 		} else if ( priv->speed == TLAN_SPEED_100 &&
 			    priv->duplex == TLAN_DUPLEX_HALF) {
 			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, 0x2000);
 		} else if ( priv->speed == TLAN_SPEED_100 &&
 			    priv->duplex == TLAN_DUPLEX_FULL) {
-			priv->tlanFullDuplex = TRUE;
+			priv->tlanFullDuplex = true;
 			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, 0x2100);
 		} else {
 
@@ -2695,7 +2695,7 @@ static void TLan_PhyStartLink( struct net_device *dev )
                 	tctl &= ~TLAN_TC_AUISEL;
 			if ( priv->duplex == TLAN_DUPLEX_FULL ) {
 				control |= MII_GC_DUPLEX;
-				priv->tlanFullDuplex = TRUE;
+				priv->tlanFullDuplex = true;
 			}
 			if ( priv->speed == TLAN_SPEED_100 ) {
 				control |= MII_GC_SPEEDSEL;
@@ -2750,9 +2750,9 @@ static void TLan_PhyFinishAutoNeg( struct net_device *dev )
 	TLan_MiiReadReg( dev, phy, MII_AN_LPA, &an_lpa );
 	mode = an_adv & an_lpa & 0x03E0;
 	if ( mode & 0x0100 ) {
-		priv->tlanFullDuplex = TRUE;
+		priv->tlanFullDuplex = true;
 	} else if ( ! ( mode & 0x0080 ) && ( mode & 0x0040 ) ) {
-		priv->tlanFullDuplex = TRUE;
+		priv->tlanFullDuplex = true;
 	}
 
 	if ( ( ! ( mode & 0x0180 ) ) &&
@@ -2855,8 +2855,8 @@ void TLan_PhyMonitor( struct net_device *dev )
 	 *	TLan_MiiReadReg
 	 *
 	 *	Returns:
-	 *		0	if ack received ok
-	 *		1	otherwise.
+	 *		false	if ack received ok
+	 *		true	if no ack received or other error
 	 *
 	 *	Parms:
 	 *		dev		The device structure containing
@@ -2875,17 +2875,17 @@ void TLan_PhyMonitor( struct net_device *dev )
 	 *
 	 **************************************************************/
 
-static int TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val )
+static bool TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val )
 {
 	u8	nack;
 	u16	sio, tmp;
  	u32	i;
-	int	err;
+	bool	err;
 	int	minten;
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	unsigned long flags = 0;
 
-	err = FALSE;
+	err = false;
 	outw(TLAN_NET_SIO, dev->base_addr + TLAN_DIO_ADR);
 	sio = dev->base_addr + TLAN_DIO_DATA + TLAN_NET_SIO;
 
@@ -2918,7 +2918,7 @@ static int TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val )
 			TLan_SetBit(TLAN_NET_SIO_MCLK, sio);
 		}
 		tmp = 0xffff;
-		err = TRUE;
+		err = true;
 	} else {					/* ACK, so read data */
 		for (tmp = 0, i = 0x8000; i; i >>= 1) {
 			TLan_ClearBit(TLAN_NET_SIO_MCLK, sio);
diff --git a/drivers/net/tlan.h b/drivers/net/tlan.h
index 4b82f28..d13ff12 100644
--- a/drivers/net/tlan.h
+++ b/drivers/net/tlan.h
@@ -31,9 +31,6 @@
 	 *
 	 ****************************************************************/
 
-#define FALSE			0
-#define TRUE			1
-
 #define TLAN_MIN_FRAME_SIZE	64
 #define TLAN_MAX_FRAME_SIZE	1600
 
-- 
1.6.6.rc0.57.gad7a


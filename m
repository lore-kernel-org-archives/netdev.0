From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 01/10] mv643xx_eth: fix NETPOLL build
Date: Wed, 16 Jul 2008 12:31:56 +0200
Message-ID: <20080716103156.GB8545@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joseph Fannin <jfannin@gmail.com>, Takashi Iwai <tiwai@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44723 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755878AbYGPKb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 06:31:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joseph Fannin <jfannin@gmail.com> and Takashi Iwai <tiwai@suse.de>
noticed that commit 073a345c04b01da0cc5b79ac7be0c7c8b1691ef5
("mv643xx_eth: clarify irq masking and unmasking") broke the
mv643xx_eth build when NETPOLL is enabled, due to it not renaming
one instance of INT_CAUSE_EXT in mv643xx_eth_netpoll().  This patch
takes care of that instance as well.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Cc: Joseph Fannin <jfannin@gmail.com>
Cc: Takashi Iwai <tiwai@suse.de>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 83a877f..8a97a00 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2112,7 +2112,7 @@ static void mv643xx_eth_netpoll(struct net_device *dev)
 
 	mv643xx_eth_irq(dev->irq, dev);
 
-	wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_CAUSE_EXT);
+	wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
 }
 #endif
 
-- 
1.5.3.4

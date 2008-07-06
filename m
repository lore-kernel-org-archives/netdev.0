From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] mv643xx_eth: fix NETPOLL build
Date: Mon, 7 Jul 2008 00:03:00 +0200
Message-ID: <20080706220300.GC12106@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dale Farnsworth <dale@farnsworth.org>,
	Joseph Fannin <jfannin@gmail.com>, Takashi Iwai <tiwai@suse.de>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52773 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755934AbYGFWDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 18:03:06 -0400
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
Cc: Dale Farnsworth <dale@farnsworth.org>
Cc: Joseph Fannin <jfannin@gmail.com>
Cc: Takashi Iwai <tiwai@suse.de>

Index: linux-2.6.26-rc8/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.26-rc8.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.26-rc8/drivers/net/mv643xx_eth.c
@@ -2120,7 +2120,7 @@ static void mv643xx_eth_netpoll(struct n
 
 	mv643xx_eth_irq(dev->irq, dev);
 
-	wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_CAUSE_EXT);
+	wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
 }
 #endif
 

--

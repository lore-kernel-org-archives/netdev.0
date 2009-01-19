From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] mv643xx_eth: prevent interrupt storm on ifconfig down
Date: Mon, 19 Jan 2009 11:09:21 +0100
Message-ID: <20090119100921.GG17124@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tbm@cyrius.com, pacman@kosh.dhis.org, netdev@vger.kernel.org,
	Matt Sealey <matt@genesi-usa.com>,
	Gabriel Paubert <paubert@iram.es>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:42743 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757277AbZASKJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 05:09:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gabriel Paubert <paubert@iram.es>

Contrary to what the docs say, the 'extended interrupt cause' bit in
the interrupt cause register (bit 1) appears to not be maskable on at
least some of the mv643xx_eth platforms, making writing zeroes to the
interrupt mask register but not the extended interrupt mask register
insufficient to stop interrupts from occuring.  Therefore, also write
zeroes to the extended interrupt mask register when shutting down the
port.

This fixes the interrupt storm seen on the Pegasos board when shutting
down the interface.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 8c6979a..5f31bbb 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2212,6 +2212,7 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 	int i;
 
+	wrlp(mp, INT_MASK_EXT, 0x00000000);
 	wrlp(mp, INT_MASK, 0x00000000);
 	rdlp(mp, INT_MASK);
 
-- 
1.5.6.4

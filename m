From: Ralf Baechle <ralf@linux-mips.org>
Subject: [METH] Don't use GFP_DMA for zone allocation.
Date: Wed, 15 Aug 2007 12:53:16 +0100
Message-ID: <20070815115316.GB5862@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:38565 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbXHOLxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 07:53:20 -0400
Received: from localhost.localdomain ([127.0.0.1]:27816 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021409AbXHOLxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 12:53:19 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IP32 doesn't even have a ZONE_DMA so no point in using GFP_DMA in any
IP32-specific device driver.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 92b403b..32bed6b 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -405,7 +405,7 @@ static void meth_rx(struct net_device* dev, unsigned long int_status)
 				priv->stats.rx_length_errors++;
 				skb = priv->rx_skbs[priv->rx_write];
 			} else {
-				skb = alloc_skb(METH_RX_BUFF_SIZE, GFP_ATOMIC | GFP_DMA);
+				skb = alloc_skb(METH_RX_BUFF_SIZE, GFP_ATOMIC);
 				if (!skb) {
 					/* Ouch! No memory! Drop packet on the floor */
 					DPRINTK("No mem: dropping packet\n");

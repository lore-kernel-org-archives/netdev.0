From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Subject: [PATCH] SGISEEQ: fix oops when doing ifconfig down; ifconfig up
Date: Sun, 13 Jan 2008 00:08:47 +0100 (CET)
Message-ID: <20080112230847.1EB3EC2F35@solo.franken.de>
Cc: ralf@linux-mips.org, jgarzik@pobox.com
To: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:59673 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbYALXIv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 18:08:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When doing init_ring checking whether a new skb needs to be allocated
was wrong.

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
---

This is a bug fix for the 2.6.25 driver.

 drivers/net/sgiseeq.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index c69bb8b..78994ed 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -193,7 +193,7 @@ static int seeq_init_ring(struct net_device *dev)
 
 	/* And now the rx ring. */
 	for (i = 0; i < SEEQ_RX_BUFFERS; i++) {
-		if (!sp->rx_desc[i].rdma.pbuf) {
+		if (!sp->rx_desc[i].skb) {
 			dma_addr_t dma_addr;
 			struct sk_buff *skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 

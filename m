From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH] i825xx: znet: fix compiler warnings when building a 64-bit kernel
Date: Fri, 14 Sep 2012 13:33:48 +0300
Message-ID: <1347618828-3136-1-git-send-email-mika.westerberg@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net,
	Mika Westerberg <mika.westerberg@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:64765 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751511Ab2INKbY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2012 06:31:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When building 64-bit kernel with this driver we get following warnings =
from
the compiler:

drivers/net/ethernet/i825xx/znet.c: In function =E2=80=98hardware_init=E2=
=80=99:
drivers/net/ethernet/i825xx/znet.c:863:29: warning: cast from pointer t=
o integer of different size [-Wpointer-to-int-cast]
drivers/net/ethernet/i825xx/znet.c:870:29: warning: cast from pointer t=
o integer of different size [-Wpointer-to-int-cast]

=46ix these by calling isa_virt_to_bus() before passing the pointers to
set_dma_addr().

Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
---
 drivers/net/ethernet/i825xx/znet.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/i825xx/znet.c b/drivers/net/ethernet/=
i825xx/znet.c
index bd1f1ef..e843624 100644
--- a/drivers/net/ethernet/i825xx/znet.c
+++ b/drivers/net/ethernet/i825xx/znet.c
@@ -860,14 +860,14 @@ static void hardware_init(struct net_device *dev)
 	disable_dma(znet->rx_dma); 		/* reset by an interrupting task. */
 	clear_dma_ff(znet->rx_dma);
 	set_dma_mode(znet->rx_dma, DMA_RX_MODE);
-	set_dma_addr(znet->rx_dma, (unsigned int) znet->rx_start);
+	set_dma_addr(znet->rx_dma, isa_virt_to_bus(znet->rx_start));
 	set_dma_count(znet->rx_dma, RX_BUF_SIZE);
 	enable_dma(znet->rx_dma);
 	/* Now set up the Tx channel. */
 	disable_dma(znet->tx_dma);
 	clear_dma_ff(znet->tx_dma);
 	set_dma_mode(znet->tx_dma, DMA_TX_MODE);
-	set_dma_addr(znet->tx_dma, (unsigned int) znet->tx_start);
+	set_dma_addr(znet->tx_dma, isa_virt_to_bus(znet->tx_start));
 	set_dma_count(znet->tx_dma, znet->tx_buf_len<<1);
 	enable_dma(znet->tx_dma);
 	release_dma_lock(flags);
--=20
1.7.10.4

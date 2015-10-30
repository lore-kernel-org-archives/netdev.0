From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2 1/2] sh_eth: fix uninitialized arrays in sh_eth_ring_init()
Date: Sat, 31 Oct 2015 02:05:56 +0300
Message-ID: <3283850.HAForN0Wed@wasted.cogentembedded.com>
References: <3291270.dPgp9opalf@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <3291270.dPgp9opalf@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sh_eth_ring_free()  called in the sh_eth_ring_init()'s error path expects
the arrays pointed  to  by 'sh_eth_private::[rt]x_skbuff' to be initialized
with NULLs but they are allocated with just kmalloc_array() and so are left
filled with random data. Use kcalloc() instead.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 2:
- fixed grammar in the change log reformatting it.

drivers/net/ethernet/renesas/sh_eth.c |    8 ++++----
 drivers/net/ethernet/renesas/sh_eth.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: net/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net/drivers/net/ethernet/renesas/sh_eth.c
@@ -1212,15 +1212,15 @@ static int sh_eth_ring_init(struct net_d
 		mdp->rx_buf_sz += NET_IP_ALIGN;
 
 	/* Allocate RX and TX skb rings */
-	mdp->rx_skbuff = kmalloc_array(mdp->num_rx_ring,
-				       sizeof(*mdp->rx_skbuff), GFP_KERNEL);
+	mdp->rx_skbuff = kcalloc(mdp->num_rx_ring, sizeof(*mdp->rx_skbuff),
+				 GFP_KERNEL);
 	if (!mdp->rx_skbuff) {
 		ret = -ENOMEM;
 		return ret;
 	}
 
-	mdp->tx_skbuff = kmalloc_array(mdp->num_tx_ring,
-				       sizeof(*mdp->tx_skbuff), GFP_KERNEL);
+	mdp->tx_skbuff = kcalloc(mdp->num_tx_ring, sizeof(*mdp->tx_skbuff),
+				 GFP_KERNEL);
 	if (!mdp->tx_skbuff) {
 		ret = -ENOMEM;
 		goto skb_ring_free;


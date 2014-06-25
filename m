From: Joe Perches <joe@perches.com>
Subject: [PATCH V3 08/22] pcnet32: Use pci_zalloc_consistent
Date: Wed, 25 Jun 2014 16:51:38 -0700
Message-ID: <1403740298.28663.2.camel@joe-AO725>
References: <cover.1403530604.git.joe@perches.com>
	 <c7cdaa8e080157cdabb92278a4c3beba89b49070.1403530604.git.joe@perches.com>
	 <1403546524.12008.2.camel@Lunix2.home>
	 <1403550950.15811.15.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Don Fry <pcnet32@frontier.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403550950.15811.15.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the now unnecessary memset too.

Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: Don Fry <pcnet32@frontier.com>
---
On Mon, 2014-06-23 at 12:15 -0700, Joe Perches wrote:
> On Mon, 2014-06-23 at 11:02 -0700, Don Fry wrote:
> > This causes the line length to be greater than 80 characters causing
> > checkpatch to complain.

V3: Use better patch prefix pcnet32, amd is too generic
V2: Don Fry is an 80 column neatnik.

Please remember this depends on patch 1/22 being applied
before this patch can be successfully applied.

 drivers/net/ethernet/amd/pcnet32.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index e7cc917..8099fdc 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -484,15 +484,14 @@ static void pcnet32_realloc_tx_ring(struct net_device *dev,
 
 	pcnet32_purge_tx_ring(dev);
 
-	new_tx_ring = pci_alloc_consistent(lp->pci_dev,
-					   sizeof(struct pcnet32_tx_head) *
-					   (1 << size),
-					   &new_ring_dma_addr);
+	new_tx_ring = pci_zalloc_consistent(lp->pci_dev,
+					    sizeof(struct pcnet32_tx_head) *
+					    (1 << size),
+					    &new_ring_dma_addr);
 	if (new_tx_ring == NULL) {
 		netif_err(lp, drv, dev, "Consistent memory allocation failed\n");
 		return;
 	}
-	memset(new_tx_ring, 0, sizeof(struct pcnet32_tx_head) * (1 << size));
 
 	new_dma_addr_list = kcalloc(1 << size, sizeof(dma_addr_t),
 				    GFP_ATOMIC);
@@ -551,15 +550,14 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 	int new, overlap;
 	unsigned int entries = 1 << size;
 
-	new_rx_ring = pci_alloc_consistent(lp->pci_dev,
-					   sizeof(struct pcnet32_rx_head) *
-					   entries,
-					   &new_ring_dma_addr);
+	new_rx_ring = pci_zalloc_consistent(lp->pci_dev,
+					    sizeof(struct pcnet32_rx_head) *
+					    entries,
+					    &new_ring_dma_addr);
 	if (new_rx_ring == NULL) {
 		netif_err(lp, drv, dev, "Consistent memory allocation failed\n");
 		return;
 	}
-	memset(new_rx_ring, 0, sizeof(struct pcnet32_rx_head) * entries);
 
 	new_dma_addr_list = kcalloc(entries, sizeof(dma_addr_t), GFP_ATOMIC);
 	if (!new_dma_addr_list)

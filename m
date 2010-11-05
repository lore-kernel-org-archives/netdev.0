From: Joe Perches <joe@perches.com>
Subject: [PATCH 25/49] drivers/net/ixgbe: Use vzalloc
Date: Thu,  4 Nov 2010 20:07:49 -0700
Message-ID: <3ef4ca9d423bd0fc5dcc8dae9c8c04ce48c9c240.1288925424.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2bd3eb4..c10d179 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4970,12 +4970,11 @@ int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
 	int size;
 
 	size = sizeof(struct ixgbe_tx_buffer) * tx_ring->count;
-	tx_ring->tx_buffer_info = vmalloc_node(size, tx_ring->numa_node);
+	tx_ring->tx_buffer_info = vzalloc_node(size, tx_ring->numa_node);
 	if (!tx_ring->tx_buffer_info)
-		tx_ring->tx_buffer_info = vmalloc(size);
+		tx_ring->tx_buffer_info = vzalloc(size);
 	if (!tx_ring->tx_buffer_info)
 		goto err;
-	memset(tx_ring->tx_buffer_info, 0, size);
 
 	/* round up to nearest 4K */
 	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
@@ -5037,15 +5036,14 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 	int size;
 
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
-	rx_ring->rx_buffer_info = vmalloc_node(size, adapter->node);
+	rx_ring->rx_buffer_info = vzalloc_node(size, adapter->node);
 	if (!rx_ring->rx_buffer_info)
-		rx_ring->rx_buffer_info = vmalloc(size);
+		rx_ring->rx_buffer_info = vzalloc(size);
 	if (!rx_ring->rx_buffer_info) {
 		e_err(probe, "vmalloc allocation failed for the Rx "
 		      "descriptor ring\n");
 		goto alloc_failed;
 	}
-	memset(rx_ring->rx_buffer_info, 0, size);
 
 	/* Round up to nearest 4K */
 	rx_ring->size = rx_ring->count * sizeof(union ixgbe_adv_rx_desc);
-- 
1.7.3.1.g432b3.dirty


------------------------------------------------------------------------------
The Next 800 Companies to Lead America's Growth: New Video Whitepaper
David G. Thomson, author of the best-selling book "Blueprint to a 
Billion" shares his insights and actions to help propel your 
business during the next growth cycle. Listen Now!
http://p.sf.net/sfu/SAP-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

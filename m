From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Subject: [PATCH 6/7] e1000e: cleanup: swap arguments to avoid
	checkpatch errors
Date: Thu,  9 Dec 2010 02:40:56 +0000
Message-ID: <1291862457-16671-7-git-send-email-asbjorn__17894.4934196354$1291863648$gmane$org@asbjorn.biz>
References: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
In-Reply-To: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Swap argument order in order to avoid checkpatch treating it as an
unary operation, instead of an binary one, and obtain consistency
with the 3 other similar assignments in netdev.c (tdlen & rdlen).

This patch fixes 3 checkpatch errors.

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
---
 drivers/net/e1000e/netdev.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index bb6a1f5..bdd3774 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2059,7 +2059,7 @@ int e1000e_setup_tx_resources(struct e1000_adapter *adapter)
 	struct e1000_ring *tx_ring = adapter->tx_ring;
 	int err = -ENOMEM, size;
 
-	size = sizeof(struct e1000_buffer) * tx_ring->count;
+	size = tx_ring->count * sizeof(struct e1000_buffer);
 	tx_ring->buffer_info = vzalloc(size);
 	if (!tx_ring->buffer_info)
 		goto err;
@@ -2094,7 +2094,7 @@ int e1000e_setup_rx_resources(struct e1000_adapter *adapter)
 	struct e1000_buffer *buffer_info;
 	int i, size, desc_len, err = -ENOMEM;
 
-	size = sizeof(struct e1000_buffer) * rx_ring->count;
+	size = rx_ring->count * sizeof(struct e1000_buffer);
 	rx_ring->buffer_info = vzalloc(size);
 	if (!rx_ring->buffer_info)
 		goto err;
@@ -2151,7 +2151,7 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter)
 		e1000_put_txbuf(adapter, buffer_info);
 	}
 
-	size = sizeof(struct e1000_buffer) * tx_ring->count;
+	size = tx_ring->count * sizeof(struct e1000_buffer);
 	memset(tx_ring->buffer_info, 0, size);
 
 	memset(tx_ring->desc, 0, tx_ring->size);
-- 
1.7.2.3


------------------------------------------------------------------------------
This SF Dev2Dev email is sponsored by:

WikiLeaks The End of the Free Internet
http://p.sf.net/sfu/therealnews-com
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

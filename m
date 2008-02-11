From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 6/6] ixgbe: remove accidentally added #ifdef
Date: Mon, 11 Feb 2008 09:26:06 -0800
Message-ID: <20080211172606.29090.59008.stgit@localhost.localdomain>
References: <20080211172539.29090.99369.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080211172539.29090.99369.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Let's not add these #ifdef NETIF_F_TSO's back.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a4aeaec..540b647 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -220,7 +220,6 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 			tx_ring->stats.bytes += tx_buffer_info->length;
 			if (cleaned) {
 				struct sk_buff *skb = tx_buffer_info->skb;
-#ifdef NETIF_F_TSO
 				unsigned int segs, bytecount;
 				segs = skb_shinfo(skb)->gso_segs ?: 1;
 				/* multiply data chunks by size of headers */
@@ -228,10 +227,6 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 					    skb->len;
 				total_tx_packets += segs;
 				total_tx_bytes += bytecount;
-#else
-				total_tx_packets++;
-				total_tx_bytes += skb->len;
-#endif
 			}
 			ixgbe_unmap_and_free_tx_resource(adapter,
 							 tx_buffer_info);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/

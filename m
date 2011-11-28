From: Cong Wang <amwang@redhat.com>
Subject: [UPDATED PATCH 21/62] net: remove the second argument
	of k[un]map_atomic()
Date: Mon, 28 Nov 2011 15:48:31 +0800
Message-ID: <1322466513-10730-1-git-send-email-amwang@redhat.com>
References: <1322371662-26166-22-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, Jiri Pirko <jpirko@redhat.com>,
	e1000-devel@lists.sourceforge.net, Dean Nelson <dnelson@redhat.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, Ian Campbell <ian.campbell@citrix.com>
To: linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1322371662-26166-22-git-send-email-amwang@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |    6 ++----
 drivers/net/ethernet/intel/e1000e/netdev.c    |   10 ++++------
 drivers/net/ethernet/sun/cassini.c            |    4 ++--
 3 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index cf480b5..b194beb 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3878,11 +3878,9 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				if (length <= copybreak &&
 				    skb_tailroom(skb) >= length) {
 					u8 *vaddr;
-					vaddr = kmap_atomic(buffer_info->page,
-					                    KM_SKB_DATA_SOFTIRQ);
+					vaddr = kmap_atomic(buffer_info->page);
 					memcpy(skb_tail_pointer(skb), vaddr, length);
-					kunmap_atomic(vaddr,
-					              KM_SKB_DATA_SOFTIRQ);
+					kunmap_atomic(vaddr);
 					/* re-use the page, so don't erase
 					 * buffer_info->page */
 					skb_put(skb, length);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a855db1..8603c87 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1272,9 +1272,9 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 			 */
 			dma_sync_single_for_cpu(&pdev->dev, ps_page->dma,
 						PAGE_SIZE, DMA_FROM_DEVICE);
-			vaddr = kmap_atomic(ps_page->page, KM_SKB_DATA_SOFTIRQ);
+			vaddr = kmap_atomic(ps_page->page);
 			memcpy(skb_tail_pointer(skb), vaddr, l1);
-			kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
+			kunmap_atomic(vaddr);
 			dma_sync_single_for_device(&pdev->dev, ps_page->dma,
 						   PAGE_SIZE, DMA_FROM_DEVICE);
 
@@ -1465,12 +1465,10 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				if (length <= copybreak &&
 				    skb_tailroom(skb) >= length) {
 					u8 *vaddr;
-					vaddr = kmap_atomic(buffer_info->page,
-					                   KM_SKB_DATA_SOFTIRQ);
+					vaddr = kmap_atomic(buffer_info->page);
 					memcpy(skb_tail_pointer(skb), vaddr,
 					       length);
-					kunmap_atomic(vaddr,
-					              KM_SKB_DATA_SOFTIRQ);
+					kunmap_atomic(vaddr);
 					/* re-use the page, so don't erase
 					 * buffer_info->page */
 					skb_put(skb, length);
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index fd40988..c22a195 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -104,8 +104,8 @@
 #include <asm/byteorder.h>
 #include <asm/uaccess.h>
 
-#define cas_page_map(x)      kmap_atomic((x), KM_SKB_DATA_SOFTIRQ)
-#define cas_page_unmap(x)    kunmap_atomic((x), KM_SKB_DATA_SOFTIRQ)
+#define cas_page_map(x)      kmap_atomic((x))
+#define cas_page_unmap(x)    kunmap_atomic((x))
 #define CAS_NCPUS            num_online_cpus()
 
 #define cas_skb_release(x)  netif_rx(x)
-- 
1.7.4.4


------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure 
contains a definitive record of customers, application performance, 
security threats, fraudulent activity, and more. Splunk takes this 
data and makes sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-novd2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] e1000: fix wrong queue idx
	calculation
Date: Sun, 20 Oct 2013 16:15:24 +0800
Message-ID: <1382256924-12598-1-git-send-email-zhiguohong@tencent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Hong Zhiguo <zhiguohong@tencent.com>
To: davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Hong Zhiguo <zhiguohong@tencent.com>

tx_ring and adapter->tx_ring are already of type "struct
e1000_tx_ring *"

Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 59ad007..ad6800a 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3917,8 +3917,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 			      "  next_to_watch        <%x>\n"
 			      "  jiffies              <%lx>\n"
 			      "  next_to_watch.status <%x>\n",
-				(unsigned long)((tx_ring - adapter->tx_ring) /
-					sizeof(struct e1000_tx_ring)),
+				(unsigned long)(tx_ring - adapter->tx_ring),
 				readl(hw->hw_addr + tx_ring->tdh),
 				readl(hw->hw_addr + tx_ring->tdt),
 				tx_ring->next_to_use,
-- 
1.8.1.2


------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60135031&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

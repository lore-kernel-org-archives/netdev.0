From: xuyongjiande@gmail.com
Subject: [PATCH] e1000: remove the check: skb->len<=0
Date: Tue, 13 May 2014 13:07:09 +0800
Message-ID: <1399957629-13536-1-git-send-email-xuyongjiande@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Yongjian Xu <xuyongjiande@gmail.com>
To: eric.dumazet@gmail.com
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

From: Yongjian Xu <xuyongjiande@gmail.com>

There is no case skb->len would be 0 or 'negative'.
Remove the check.

Signed-off-by: Yongjian Xu <xuyongjiande@gmail.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 27058df..660971f 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3105,11 +3105,6 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	 */
 	tx_ring = adapter->tx_ring;
 
-	if (unlikely(skb->len <= 0)) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
-
 	/* On PCI/PCI-X HW, if packet size is less than ETH_ZLEN,
 	 * packets may get corrupted during padding by HW.
 	 * To WA this issue, pad all small packets manually.
-- 
1.9.1


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

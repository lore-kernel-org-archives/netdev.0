From: Prasanna Panchamukhi <ppanchamukhi@riverbed.com>
Subject: [PATCH] net/e1000e : Fix to use dev_kfree_skb_any()
 instead of dev_kfree_skb() in _jumbo_rx_irq
Date: Fri, 17 Dec 2010 14:31:24 -0800
Message-ID: <4D0BE4BC.10004@riverbed.com>
Reply-To: prasanna.panchamukhi@riverbed.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
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


Several "Warning: kfree_skb on hard IRQ" messages have been observed from
the net/e1000e driver, e1000_clean_jumbo_rx_irq() routine calling
dev_kfree_skb(). This patch fixes the above warning messages by
calling dev_kfree_skb_any() instead of dev_kfree_skb().

Signed-off-by: Prasanna S. Panchamukhi<prasanna.panchamukhi@riverbed.com>
---
  drivers/net/e1000e/netdev.c |    4 ++--
  1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c4ca162..1068abc 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1320,7 +1320,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
  				/* an error means any chain goes out the window
  				 * too */
  				if (rx_ring->rx_skb_top)
-					dev_kfree_skb(rx_ring->rx_skb_top);
+					dev_kfree_skb_any(rx_ring->rx_skb_top);
  				rx_ring->rx_skb_top = NULL;
  				goto next_desc;
  		}
@@ -1393,7 +1393,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
  		/* eth type trans needs skb->data to point to something */
  		if (!pskb_may_pull(skb, ETH_HLEN)) {
  			e_err("pskb_may_pull failed.\n");
-			dev_kfree_skb(skb);
+			dev_kfree_skb_any(skb);
  			goto next_desc;
  		}

-- 
1.7.0.4



------------------------------------------------------------------------------
Lotusphere 2011
Register now for Lotusphere 2011 and learn how
to connect the dots, take your collaborative environment
to the next level, and enter the era of Social Business.
http://p.sf.net/sfu/lotusphere-d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

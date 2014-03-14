From: Jakub Kicinski <kubakici@wp.pl>
Subject: [PATCH net-next 04/10] ixgbe: remove redundant if
	clause from PTP work
Date: Fri, 14 Mar 2014 18:34:35 +0100
Message-ID: <1394818481-7652-5-git-send-email-kubakici@wp.pl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <kubakici@wp.pl>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

ptp_tx_skb is always set before work is scheduled,
work is cancelled before ptp_tx_skb is set to NULL.
PTP work cannot ever see ptp_tx_skb set to NULL.

Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 44ac9ae..8b527d7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -512,10 +512,6 @@ static void ixgbe_ptp_tx_hwtstamp_work(struct work_struct *work)
 					      IXGBE_PTP_TX_TIMEOUT);
 	u32 tsynctxctl;
 
-	/* we have to have a valid skb */
-	if (!adapter->ptp_tx_skb)
-		return;
-
 	if (timeout) {
 		dev_kfree_skb_any(adapter->ptp_tx_skb);
 		adapter->ptp_tx_skb = NULL;
-- 
1.8.5.3


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

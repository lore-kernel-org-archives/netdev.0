From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] e100: dump small buffers via %*ph
Date: Wed, 29 May 2013 13:01:58 +0300
Message-ID: <1369821718-1460-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>
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

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/intel/e100.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index d2bea3f..68849cc 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -1175,15 +1175,12 @@ static int e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 		config->rx_discard_short_frames = 0x0;  /* 1=discard, 0=save */
 	}
 
-	netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
-		     "[00-07]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
-		     c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7]);
-	netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
-		     "[08-15]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
-		     c[8], c[9], c[10], c[11], c[12], c[13], c[14], c[15]);
-	netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
-		     "[16-23]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
-		     c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23]);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev, "[00-07]=%8ph\n",
+		     c + 0);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev, "[08-15]=%8ph\n",
+		     c + 8);
+	netif_printk(nic, hw, KERN_DEBUG, nic->netdev, "[16-23]=%8ph\n",
+		     c + 16);
 	return 0;
 }
 
-- 
1.8.2.rc0.22.gb3600c3


------------------------------------------------------------------------------
Introducing AppDynamics Lite, a free troubleshooting tool for Java/.NET
Get 100% visibility into your production application - at no cost.
Code-level diagnostics for performance bottlenecks with <2% overhead
Download for free and get started troubleshooting in minutes.
http://p.sf.net/sfu/appdyn_d2d_ap1
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

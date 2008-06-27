From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 11/18] igb: reenable CRC stripping in
	hardware
Date: Fri, 27 Jun 2008 11:01:12 -0700
Message-ID: <20080627180109.22428.31734.stgit@localhost.localdomain>
References: <20080627175921.22428.52767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080627175921.22428.52767.stgit@localhost.localdomain>
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

From: Auke Kok <auke-jan.h.kok@intel.com>

We can remove a clunky workaround for not having the hardware
strip the CRC. 82575 silicon as well as the older PCI Express
e1000e hardware all work OK in this respect.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 501ab4e..27fca76 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1637,10 +1637,12 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
 		(adapter->hw.mac.mc_filter_type << E1000_RCTL_MO_SHIFT);
 
-	/* disable the stripping of CRC because it breaks
-	 * BMC firmware connected over SMBUS
-	rctl |= E1000_RCTL_SECRC;
+	/*
+	 * enable stripping of CRC. It's unlikely this will break BMC
+	 * redirection as it did with e1000. Newer features require
+	 * that the HW strips the CRC.
 	*/
+	rctl |= E1000_RCTL_SECRC;
 
 	rctl &= ~E1000_RCTL_SBP;
 
@@ -3717,7 +3719,6 @@ static bool igb_clean_rx_irq_adv(struct igb_ring *rx_ring,
 			}
 		}
 send_up:
-		pskb_trim(skb, skb->len - 4);
 		i++;
 		if (i == rx_ring->count)
 			i = 0;


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php

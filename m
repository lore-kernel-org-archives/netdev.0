From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH] gianfar: Call gfar_halt_nodisable() from gfar_halt().
Date: Tue, 12 Aug 2008 15:10:46 -0500
Message-ID: <20080812201046.GC27956@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

gfar_halt() was factored out into halting and disabling by commit
d87eb12785c14de1586e3bad86ca2c0991300339, as the suspend() method
only wants to do the former.  However, the call to gfar_halt_nodisable()
from gfar_halt() apparently got lost during the patch respin process.

This adds it back.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/gianfar.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index ca6cf6e..999d691 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -134,9 +134,7 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb, int l
 static void gfar_vlan_rx_register(struct net_device *netdev,
 		                struct vlan_group *grp);
 void gfar_halt(struct net_device *dev);
-#ifdef CONFIG_PM
 static void gfar_halt_nodisable(struct net_device *dev);
-#endif
 void gfar_start(struct net_device *dev);
 static void gfar_clear_exact_match(struct net_device *dev);
 static void gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr);
@@ -631,7 +629,6 @@ static void init_registers(struct net_device *dev)
 }
 
 
-#ifdef CONFIG_PM
 /* Halt the receive and transmit queues */
 static void gfar_halt_nodisable(struct net_device *dev)
 {
@@ -657,7 +654,6 @@ static void gfar_halt_nodisable(struct net_device *dev)
 			cpu_relax();
 	}
 }
-#endif
 
 /* Halt the receive and transmit queues */
 void gfar_halt(struct net_device *dev)
@@ -666,6 +662,8 @@ void gfar_halt(struct net_device *dev)
 	struct gfar __iomem *regs = priv->regs;
 	u32 tempval;
 
+	gfar_halt_nodisable(dev);
+
 	/* Disable Rx and Tx */
 	tempval = gfar_read(&regs->maccfg1);
 	tempval &= ~(MACCFG1_RX_EN | MACCFG1_TX_EN);
-- 
1.5.6.rc1.6.gc53ad.dirty

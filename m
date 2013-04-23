From: Markus Brunner <systemprogrammierung.brunner@gmail.com>
Subject: [PATCH] remove vlan tags in CPSW dual emac mode
Date: Tue, 23 Apr 2013 18:18:47 +0200
Message-ID: <4699400.vD3TdgH1nR@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, Mark Jackson <mpfj-list@newflow.co.uk>,
	systemprogrammierung.brunner@gmail.com
To: netdev@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If operating in dual emac mode all packets sent by the CPSW contain vlan headers with the reserved VID 0, 
which gets stripped away by all somewhat recent Linux versions. Operating systems without that behaviour will fail to communicate. 
This patch fixes that behaviour by disabling the VLAN_AWARE mode as already described by the comment above.

Signed-off-by: Markus Brunner <systemprogrammierung.brunner@gmail.com>
Tested-by: Mark Jackson <mpfj@newflow.co.uk>

---
--- linux-3.9-rc8.orig/drivers/net/ethernet/ti/cpsw.c	2013-04-23 17:26:11.000000000 +0200
+++ linux-3.9-rc8/drivers/net/ethernet/ti/cpsw.c	2013-04-23 17:36:25.000000000 +0200
@@ -751,9 +751,9 @@ static void cpsw_init_host_port(struct c
 	/* switch to vlan unaware mode */
 	cpsw_ale_control_set(priv->ale, priv->host_port, ALE_VLAN_AWARE,
 			     CPSW_ALE_VLAN_AWARE);
 	control_reg = readl(&priv->regs->control);
-	control_reg |= CPSW_VLAN_AWARE;
+	control_reg &= ~CPSW_VLAN_AWARE;
 	writel(control_reg, &priv->regs->control);
 	fifo_mode = (priv->data.dual_emac) ? CPSW_FIFO_DUAL_MAC_MODE :
 		     CPSW_FIFO_NORMAL_MODE;
 	writel(fifo_mode, &priv->host_port_regs->tx_in_ctl);

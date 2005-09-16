From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: fix spider_net media detection
Date: Fri, 16 Sep 2005 08:55:33 +0200
Message-ID: <200509160855.34219.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, linuxppc64-dev@ozlabs.org,
	osterkam@de.ibm.com
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: jgarzik@pobox.com
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>

This patch makes the driver work with any BladeCenter
network switch, it used to work only with certain
models.

Please apply.

Signed-off-by: Arnd Bergmann <arndb@de.ibm.com>

--- linux-2.6.13.orig/drivers/net/spider_net.c
+++ linux-2.6.13/drivers/net/spider_net.c
@@ -1817,6 +1817,10 @@ spider_net_setup_phy(struct spider_net_c
 	/* LEDs active in both modes, autosense prio = fiber */
 	spider_net_write_phy(card->netdev, 1, MII_NCONFIG, 0x945f);
 
+	/* switch off fibre autoneg */
+	spider_net_write_phy(card->netdev, 1, MII_NCONFIG, 0xfc01);
+	spider_net_write_phy(card->netdev, 1, 0x0b, 0x0004);
+
 	phy->def->ops->read_link(phy);
 	pr_info("Found %s with %i Mbps, %s-duplex.\n", phy->def->name,
 		phy->speed, phy->duplex==1 ? "Full" : "Half");

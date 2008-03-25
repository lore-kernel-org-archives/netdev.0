From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 2.6.24-stable] ehea: Fix IPv6 support
Date: Tue, 25 Mar 2008 16:56:15 +0100
Message-ID: <200803251656.16065.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Hannes Hering <hering2@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: stable@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757216AbYCYP43@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Indicate that HEA calculates IPv4 checksums only

Signed-off-by: Thomas Klein <tklein@de.ibm.com>

---
diff -Nurp linux-2.6.24.4.org/drivers/net/ehea/ehea.h linux-2.6.24.4/drivers/net/ehea/ehea.h
--- linux-2.6.24.4.org/drivers/net/ehea/ehea.h	2008-03-25 12:42:18.000000000 +0100
+++ linux-2.6.24.4/drivers/net/ehea/ehea.h	2008-03-25 13:13:29.000000000 +0100
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0083"
+#define DRV_VERSION	"EHEA_0083a"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff -Nurp linux-2.6.24.4.org/drivers/net/ehea/ehea_main.c linux-2.6.24.4/drivers/net/ehea/ehea_main.c
--- linux-2.6.24.4.org/drivers/net/ehea/ehea_main.c	2008-03-25 12:42:18.000000000 +0100
+++ linux-2.6.24.4/drivers/net/ehea/ehea_main.c	2008-03-25 13:13:12.000000000 +0100
@@ -2945,7 +2945,7 @@ struct ehea_port *ehea_setup_single_port
 	dev->vlan_rx_add_vid = ehea_vlan_rx_add_vid;
 	dev->vlan_rx_kill_vid = ehea_vlan_rx_kill_vid;
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
-		      | NETIF_F_HIGHDMA | NETIF_F_HW_CSUM | NETIF_F_HW_VLAN_TX
+		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
 		      | NETIF_F_LLTX;
 	dev->tx_timeout = &ehea_tx_watchdog;

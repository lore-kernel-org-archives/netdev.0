From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/3] ehea: Remove remnants of LRO support
Date: Fri, 16 Nov 2012 22:46:43 +0000
Message-ID: <1353106003.2743.55.camel@bwh-desktop.uk.solarflarecom.com>
References: <1353105635.2743.49.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23206 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761Ab2KPWqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 17:46:46 -0500
In-Reply-To: <1353105635.2743.49.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2cb1deb56f5bf413da83491e0cb5a0474393c8ef ('ehea: Remove LRO
support') left behind the Kconfig depends/select and feature flag.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This is not even compile-tested, as I don't have a suitable
cross-compiler to hand.

Ben.

 drivers/net/ethernet/ibm/Kconfig          |    5 ++---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |    2 +-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ibm/Kconfig b/drivers/net/ethernet/ibm/Kconfig
index b9773d2..6529d31 100644
--- a/drivers/net/ethernet/ibm/Kconfig
+++ b/drivers/net/ethernet/ibm/Kconfig
@@ -6,7 +6,7 @@ config NET_VENDOR_IBM
 	bool "IBM devices"
 	default y
 	depends on MCA || PPC_PSERIES || PPC_PSERIES || PPC_DCR || \
-		   (IBMEBUS && INET && SPARSEMEM)
+		   (IBMEBUS && SPARSEMEM)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -33,8 +33,7 @@ source "drivers/net/ethernet/ibm/emac/Kconfig"
 
 config EHEA
 	tristate "eHEA Ethernet support"
-	depends on IBMEBUS && INET && SPARSEMEM
-	select INET_LRO
+	depends on IBMEBUS && SPARSEMEM
 	---help---
 	  This driver supports the IBM pSeries eHEA ethernet adapter.
 
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index f4d2da0..09faf33 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3028,7 +3028,7 @@ static struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	ehea_set_ethtool_ops(dev);
 
 	dev->hw_features = NETIF_F_SG | NETIF_F_TSO
-		      | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX | NETIF_F_LRO;
+		      | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX;
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/7] net: set dev->addr_assign_type correctly
Date: Tue,  1 Jan 2013 14:30:15 +0100
Message-ID: <1357047019-1037-4-git-send-email-jiri@resnulli.us>
References: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	sassmann@redhat.com, kaber@trash.net, richard@nod.at
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:50575 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315Ab3AANag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2013 08:30:36 -0500
Received: by mail-ea0-f175.google.com with SMTP id h11so5409994eaa.20
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2013 05:30:33 -0800 (PST)
In-Reply-To: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not a bitfield, but a plain value.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c        | 2 +-
 drivers/net/ethernet/ethoc.c                    | 2 +-
 drivers/net/ethernet/lantiq_etop.c              | 2 +-
 include/linux/etherdevice.h                     | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 56d3f69..17651c7 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2540,7 +2540,7 @@ static int atl1c_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	if (atl1c_read_mac_addr(&adapter->hw)) {
 		/* got a random MAC address, set NET_ADDR_RANDOM to netdev */
-		netdev->addr_assign_type |= NET_ADDR_RANDOM;
+		netdev->addr_assign_type = NET_ADDR_RANDOM;
 	}
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
 	memcpy(netdev->perm_addr, adapter->hw.mac_addr, netdev->addr_len);
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 71b3d7d..5b0d993 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -3053,7 +3053,7 @@ static int atl1_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* copy the MAC address out of the EEPROM */
 	if (atl1_read_mac_addr(&adapter->hw)) {
 		/* mark random mac */
-		netdev->addr_assign_type |= NET_ADDR_RANDOM;
+		netdev->addr_assign_type = NET_ADDR_RANDOM;
 	}
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
 
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 8db1c06..f380bb7 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1068,7 +1068,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	}
 
 	if (random_mac)
-		netdev->addr_assign_type |= NET_ADDR_RANDOM;
+		netdev->addr_assign_type = NET_ADDR_RANDOM;
 
 	/* register MII bus */
 	priv->mdio = mdiobus_alloc();
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index c124e67..cd3d2c0 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -655,7 +655,7 @@ ltq_etop_init(struct net_device *dev)
 
 	/* Set addr_assign_type here, ltq_etop_set_mac_address would reset it. */
 	if (random_mac)
-		dev->addr_assign_type |= NET_ADDR_RANDOM;
+		dev->addr_assign_type = NET_ADDR_RANDOM;
 
 	ltq_etop_set_multicast_list(dev);
 	err = ltq_etop_mdio_init(dev);
diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 243eea1..1a43e1b 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -192,7 +192,7 @@ static inline void eth_zero_addr(u8 *addr)
  */
 static inline void eth_hw_addr_random(struct net_device *dev)
 {
-	dev->addr_assign_type |= NET_ADDR_RANDOM;
+	dev->addr_assign_type = NET_ADDR_RANDOM;
 	eth_random_addr(dev->dev_addr);
 }
 
-- 
1.8.0

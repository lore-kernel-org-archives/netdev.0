From: Otavio Salvador <otavio@ossystems.com.br>
Subject: [PATCH 1/2] net/sis900: store MAC into perm_addr for SiS 900, 630E, 635 and 96x variants
Date: Tue, 12 Apr 2011 12:30:40 -0300
Message-ID: <1302622241-11871-1-git-send-email-otavio@ossystems.com.br>
Cc: Otavio Salvador <otavio@ossystems.com.br>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:63570 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756321Ab1DLPax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 11:30:53 -0400
Received: by yxs7 with SMTP id 7so2578650yxs.19
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 08:30:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Otavio Salvador <otavio@ossystems.com.br>
---
 drivers/net/sis900.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index cb317cd..484f795 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -240,7 +240,8 @@ static const struct ethtool_ops sis900_ethtool_ops;
  *	@net_dev: the net device to get address for
  *
  *	Older SiS900 and friends, use EEPROM to store MAC address.
- *	MAC address is read from read_eeprom() into @net_dev->dev_addr.
+ *	MAC address is read from read_eeprom() into @net_dev->dev_addr and
+ *	@net_dev->perm_addr.
  */
 
 static int __devinit sis900_get_mac_addr(struct pci_dev * pci_dev, struct net_device *net_dev)
@@ -261,6 +262,9 @@ static int __devinit sis900_get_mac_addr(struct pci_dev * pci_dev, struct net_de
 	for (i = 0; i < 3; i++)
 	        ((u16 *)(net_dev->dev_addr))[i] = read_eeprom(ioaddr, i+EEPROMMACAddr);
 
+	/* Store MAC Address in perm_addr */
+	memcpy(net_dev->perm_addr, net_dev->dev_addr, ETH_ALEN);
+
 	return 1;
 }
 
@@ -271,7 +275,8 @@ static int __devinit sis900_get_mac_addr(struct pci_dev * pci_dev, struct net_de
  *
  *	SiS630E model, use APC CMOS RAM to store MAC address.
  *	APC CMOS RAM is accessed through ISA bridge.
- *	MAC address is read into @net_dev->dev_addr.
+ *	MAC address is read into @net_dev->dev_addr and
+ *	@net_dev->perm_addr.
  */
 
 static int __devinit sis630e_get_mac_addr(struct pci_dev * pci_dev,
@@ -296,6 +301,10 @@ static int __devinit sis630e_get_mac_addr(struct pci_dev * pci_dev,
 		outb(0x09 + i, 0x70);
 		((u8 *)(net_dev->dev_addr))[i] = inb(0x71);
 	}
+
+	/* Store MAC Address in perm_addr */
+	memcpy(net_dev->perm_addr, net_dev->dev_addr, ETH_ALEN);
+
 	pci_write_config_byte(isa_bridge, 0x48, reg & ~0x40);
 	pci_dev_put(isa_bridge);
 
@@ -310,7 +319,7 @@ static int __devinit sis630e_get_mac_addr(struct pci_dev * pci_dev,
  *
  *	SiS635 model, set MAC Reload Bit to load Mac address from APC
  *	to rfdr. rfdr is accessed through rfcr. MAC address is read into
- *	@net_dev->dev_addr.
+ *	@net_dev->dev_addr and @net_dev->perm_addr.
  */
 
 static int __devinit sis635_get_mac_addr(struct pci_dev * pci_dev,
@@ -334,6 +343,9 @@ static int __devinit sis635_get_mac_addr(struct pci_dev * pci_dev,
 		*( ((u16 *)net_dev->dev_addr) + i) = inw(ioaddr + rfdr);
 	}
 
+	/* Store MAC Address in perm_addr */
+	memcpy(net_dev->perm_addr, net_dev->dev_addr, ETH_ALEN);
+
 	/* enable packet filtering */
 	outl(rfcrSave | RFEN, rfcr + ioaddr);
 
@@ -353,7 +365,7 @@ static int __devinit sis635_get_mac_addr(struct pci_dev * pci_dev,
  *	EEDONE signal to refuse EEPROM access by LAN.
  *	The EEPROM map of SiS962 or SiS963 is different to SiS900.
  *	The signature field in SiS962 or SiS963 spec is meaningless.
- *	MAC address is read into @net_dev->dev_addr.
+ *	MAC address is read into @net_dev->dev_addr and @net_dev->perm_addr.
  */
 
 static int __devinit sis96x_get_mac_addr(struct pci_dev * pci_dev,
@@ -372,6 +384,9 @@ static int __devinit sis96x_get_mac_addr(struct pci_dev * pci_dev,
 			for (i = 0; i < 3; i++)
 			        ((u16 *)(net_dev->dev_addr))[i] = read_eeprom(ioaddr, i+EEPROMMACAddr);
 
+			/* Store MAC Address in perm_addr */
+			memcpy(net_dev->perm_addr, net_dev->dev_addr, ETH_ALEN);
+
 			outl(EEDONE, ee_addr);
 			return 1;
 		} else {
-- 
1.7.4.1


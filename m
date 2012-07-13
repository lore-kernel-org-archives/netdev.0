From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 4/8] wireless: Use eth_random_addr
Date: Thu, 12 Jul 2012 22:33:08 -0700
Message-ID: <93ab9a323e85d1b0d8c7eac4db7ab7835e61efe6.1342157022.git.joe@perches.com>
References: <1341968967.13724.23.camel@joe2Laptop>
Cc: Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, users@rt2x00.serialmonkey.com
To: David Miller <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Christian Lamparter <chunkeey@googlemail.com>,
	Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	Herton Ronaldo Krzesinski <herton@canonical.com>,
	Hin-Tak Leung <htl10@users.sourceforge.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341968967.13724.23.camel@joe2Laptop>
In-Reply-To: <cover.1342157022.git.joe@perches.com>
References: <cover.1342157022.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the existing uses of random_ether_addr to
the new eth_random_addr.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/adm8211.c             |    2 +-
 drivers/net/wireless/p54/eeprom.c          |    2 +-
 drivers/net/wireless/rt2x00/rt2400pci.c    |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c    |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c    |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c    |    2 +-
 drivers/net/wireless/rt2x00/rt61pci.c      |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c      |    2 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c |    2 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c |    2 +-
 10 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index 97afcec..689a71c 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1854,7 +1854,7 @@ static int __devinit adm8211_probe(struct pci_dev *pdev,
 	if (!is_valid_ether_addr(perm_addr)) {
 		printk(KERN_WARNING "%s (adm8211): Invalid hwaddr in EEPROM!\n",
 		       pci_name(pdev));
-		random_ether_addr(perm_addr);
+		eth_random_addr(perm_addr);
 	}
 	SET_IEEE80211_PERM_ADDR(dev, perm_addr);
 
diff --git a/drivers/net/wireless/p54/eeprom.c b/drivers/net/wireless/p54/eeprom.c
index 636daf2..1403709 100644
--- a/drivers/net/wireless/p54/eeprom.c
+++ b/drivers/net/wireless/p54/eeprom.c
@@ -857,7 +857,7 @@ good_eeprom:
 
 		wiphy_warn(dev->wiphy,
 			   "Invalid hwaddr! Using randomly generated MAC addr\n");
-		random_ether_addr(perm_addr);
+		eth_random_addr(perm_addr);
 		SET_IEEE80211_PERM_ADDR(dev, perm_addr);
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index 5e6b501..8b9dbd7 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -1455,7 +1455,7 @@ static int rt2400pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
-		random_ether_addr(mac);
+		eth_random_addr(mac);
 		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index 136b849..d2cf8a4 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -1585,7 +1585,7 @@ static int rt2500pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
-		random_ether_addr(mac);
+		eth_random_addr(mac);
 		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 669aecd..3aae36b 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -1352,7 +1352,7 @@ static int rt2500usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
-		random_ether_addr(mac);
+		eth_random_addr(mac);
 		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless/rt2x00/rt2800lib.c
index 068276e..d857d55 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -4340,7 +4340,7 @@ int rt2800_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
-		random_ether_addr(mac);
+		eth_random_addr(mac);
 		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index ee22bd7..f322596 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -2415,7 +2415,7 @@ static int rt61pci_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
-		random_ether_addr(mac);
+		eth_random_addr(mac);
 		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index 77ccbbc..ba6e434 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -1770,7 +1770,7 @@ static int rt73usb_validate_eeprom(struct rt2x00_dev *rt2x00dev)
 	 */
 	mac = rt2x00_eeprom_addr(rt2x00dev, EEPROM_MAC_ADDR_0);
 	if (!is_valid_ether_addr(mac)) {
-		random_ether_addr(mac);
+		eth_random_addr(mac);
 		EEPROM(rt2x00dev, "MAC: %pM\n", mac);
 	}
 
diff --git a/drivers/net/wireless/rtl818x/rtl8180/dev.c b/drivers/net/wireless/rtl818x/rtl8180/dev.c
index 3b50539..aceaf68 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/dev.c
@@ -1078,7 +1078,7 @@ static int __devinit rtl8180_probe(struct pci_dev *pdev,
 	if (!is_valid_ether_addr(mac_addr)) {
 		printk(KERN_WARNING "%s (rtl8180): Invalid hwaddr! Using"
 		       " randomly generated MAC addr\n", pci_name(pdev));
-		random_ether_addr(mac_addr);
+		eth_random_addr(mac_addr);
 	}
 	SET_IEEE80211_PERM_ADDR(dev, mac_addr);
 
diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net/wireless/rtl818x/rtl8187/dev.c
index 4fb1ca1..71a30b0 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
@@ -1486,7 +1486,7 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
 	if (!is_valid_ether_addr(mac_addr)) {
 		printk(KERN_WARNING "rtl8187: Invalid hwaddr! Using randomly "
 		       "generated MAC address\n");
-		random_ether_addr(mac_addr);
+		eth_random_addr(mac_addr);
 	}
 	SET_IEEE80211_PERM_ADDR(dev, mac_addr);
 
-- 
1.7.8.111.gad25c.dirty

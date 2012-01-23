From: "Torne (Richard Coles)" <torne@google.com>
Subject: [PATCH] r8169: Randomise invalid MAC addresses
Date: Mon, 23 Jan 2012 18:32:20 +0000
Message-ID: <1327343540-30348-1-git-send-email-torne@google.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Torne (Richard Coles)" <torne@google.com>
To: nic_swsd@realtek.com, romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Torne (Richard Coles)" <torne@google.com>

If the default MAC address stored in the card is invalid, replace it
with a random address and complain about it.

Signed-off-by: Torne (Richard Coles) <torne@google.com>
---
 drivers/net/ethernet/realtek/r8169.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7a0c800..ec5ebbb 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4103,6 +4103,14 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Get MAC address */
 	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
+
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		/* Report it and use a random ethernet address instead */
+		netdev_err(dev, "Invalid MAC address: %pM\n", dev->dev_addr);
+		random_ether_addr(dev->dev_addr);
+		netdev_info(dev, "Using random MAC address: %pM\n",
+			    dev->dev_addr);
+	}
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
-- 
1.7.7.3

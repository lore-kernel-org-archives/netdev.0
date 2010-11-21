From: Joe Perches <joe@perches.com>
Subject: [PATCH 45/62] tulip: Use static const
Date: Sat, 20 Nov 2010 18:38:46 -0800
Message-ID: <4c1199b4113c60eb7abe7c9063bc7acb7aab3888.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  26150	    657	   5416	  32223	   7ddf	drivers/net/tulip/tulip_core.o.new
  26054	    741	   5416	  32211	   7dd3	drivers/net/tulip/tulip_core.o.old

Use DEFINE_PCI_DEVICE_TABLE for local declaration.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/tulip_core.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 2c39f25..5c01e26 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1302,17 +1302,18 @@ static const struct net_device_ops tulip_netdev_ops = {
 #endif
 };
 
+DEFINE_PCI_DEVICE_TABLE(early_486_chipsets) = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82424) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_496) },
+	{ },
+};
+
 static int __devinit tulip_init_one (struct pci_dev *pdev,
 				     const struct pci_device_id *ent)
 {
 	struct tulip_private *tp;
 	/* See note below on the multiport cards. */
 	static unsigned char last_phys_addr[6] = {0x00, 'L', 'i', 'n', 'u', 'x'};
-	static struct pci_device_id early_486_chipsets[] = {
-		{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82424) },
-		{ PCI_DEVICE(PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_496) },
-		{ },
-	};
 	static int last_irq;
 	static int multiport_cnt;	/* For four-port boards w/one EEPROM */
 	int i, irq;
@@ -1682,7 +1683,9 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
 		tp->full_duplex_lock = 1;
 
 	if (tulip_media_cap[tp->default_port] & MediaIsMII) {
-		u16 media2advert[] = { 0x20, 0x40, 0x03e0, 0x60, 0x80, 0x100, 0x200 };
+		static const u16 media2advert[] = {
+			0x20, 0x40, 0x03e0, 0x60, 0x80, 0x100, 0x200
+		};
 		tp->mii_advertise = media2advert[tp->default_port - 9];
 		tp->mii_advertise |= (tp->flags & HAS_8023X); /* Matching bits! */
 	}
-- 
1.7.3.2.245.g03276.dirty

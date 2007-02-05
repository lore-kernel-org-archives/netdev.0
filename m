From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH 02/02] misc-net-drivers: Use ARRAY_SIZE macro when appropriate
Date: Mon, 5 Feb 2007 18:57:51 +0200
Message-ID: <20070205165751.GH3896@Ahmed>
References: <20070205165657.GG3896@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932189AbXBEQ6A@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070205165657.GG3896@Ahmed>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

A 2.6.20 patch to use ARRAY_SIZE macro already defined in kernel.h for some
miscellaneous network drivers with no specific maintaners.

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
---
Patch isn't compile-tested due to missing hardware.

diff --git a/drivers/net/apne.c b/drivers/net/apne.c
index 9541911..8806151 100644
--- a/drivers/net/apne.c
+++ b/drivers/net/apne.c
@@ -247,7 +247,7 @@ static int __init apne_probe1(struct net_device *dev, int ioaddr)
 	    {0x00,	NE_EN0_RSARHI},
 	    {E8390_RREAD+E8390_START, NE_CMD},
 	};
-	for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++) {
+	for (i = 0; i < ARRAY_SIZE(program_seq); i++) {
 	    outb(program_seq[i].value, ioaddr + program_seq[i].offset);
 	}
 
diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index ddd12d4..200cbc0 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -414,7 +414,7 @@ static void am79c961_setmulticastlist (struct net_device *dev)
 	/*
 	 * Update the multicast hash table
 	 */
-	for (i = 0; i < sizeof(multi_hash) / sizeof(multi_hash[0]); i++)
+	for (i = 0; i < ARRAY_SIZE(multi_hash); i++)
 		write_rreg(dev->base_addr, i + LADRL, multi_hash[i]);
 
 	/*
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index 7e37ac8..ef18428 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -263,7 +263,7 @@ struct lance_addr {
 									   (highest byte stripped) */
 };
 
-#define	N_LANCE_ADDR	(sizeof(lance_addr_list)/sizeof(*lance_addr_list))
+#define	N_LANCE_ADDR	ARRAY_SIZE(lance_addr_list)
 
 
 /* Definitions for the Lance */
diff --git a/drivers/net/fec_8xx/fec_mii.c b/drivers/net/fec_8xx/fec_mii.c
index d3c16b8..1fc2b43 100644
--- a/drivers/net/fec_8xx/fec_mii.c
+++ b/drivers/net/fec_8xx/fec_mii.c
@@ -310,12 +310,12 @@ int fec_mii_phy_id_detect(struct net_device *dev)
 		return -1;
 	}
 
-	for (i = 0, phy = phy_info; i < sizeof(phy_info) / sizeof(phy_info[0]);
+	for (i = 0, phy = phy_info; i < ARRAY_SIZE(phy_info));
 	     i++, phy++)
 		if (phy->id == (phy_hwid >> 4) || phy->id == 0)
 			break;
 
-	if (i >= sizeof(phy_info) / sizeof(phy_info[0])) {
+	if (i >= ARRAY_SIZE(phy_info)) {
 		printk(KERN_ERR DRV_MODULE_NAME
 		       ": %s PHY id 0x%08x is not supported!\n",
 		       dev->name, phy_hwid);
diff --git a/drivers/net/ne-h8300.c b/drivers/net/ne-h8300.c
index 38fd525..7599d77 100644
--- a/drivers/net/ne-h8300.c
+++ b/drivers/net/ne-h8300.c
@@ -259,7 +259,7 @@ static int __init ne_probe1(struct net_device *dev, int ioaddr)
 			{E8390_RREAD+E8390_START, E8390_CMD},
 		};
 
-		for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++)
+		for (i = 0; i < ARRAY_SIZE(program_seq); i++)
 			outb_p(program_seq[i].value, ioaddr + program_seq[i].offset);
 
 	}
diff --git a/drivers/net/zorro8390.c b/drivers/net/zorro8390.c
index d85e2ea..29f9750 100644
--- a/drivers/net/zorro8390.c
+++ b/drivers/net/zorro8390.c
@@ -191,7 +191,7 @@ static int __devinit zorro8390_init(struct net_device *dev,
 	    {0x00,	NE_EN0_RSARHI},
 	    {E8390_RREAD+E8390_START, NE_CMD},
 	};
-	for (i = 0; i < sizeof(program_seq)/sizeof(program_seq[0]); i++) {
+	for (i = 0; i < ARRAY_SIZE(program_seq); i++) {
 	    z_writeb(program_seq[i].value, ioaddr + program_seq[i].offset);
 	}
     }


-- 
Ahmed S. Darwish
http://darwish-07.blogspot.com

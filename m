From: Kumar Gala <galak@gate.crashing.org>
Subject: [PATCH] gianfar mii: Use proper resource for MII memory region
Date: Thu, 5 Jan 2006 09:42:44 -0600 (CST)
Message-ID: <Pine.LNX.4.44.0601050942020.31237-100000@gate.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, <linux-kernel@vger.kernel.org>,
	<afleming@freescale.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751439AbWAEPsx@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We can now have the gianfar mii platform device have a proper
resource for the IO memory region for its registers.  Previously
we passed this information that the platform_data structure because
we couldn't handle overlapping memory regions for platform devices.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

---
commit 7b5d230825fc228414dce7dc2bfdace4ecea4613
tree f822e58596f00a8e18e01e959630a59d95552d4e
parent 470500bb2f548d79e8981e4b1d9841f3d01dd657
author Kumar Gala <galak@kernel.crashing.org> Thu, 05 Jan 2006 09:33:44 -0600
committer Kumar Gala <galak@kernel.crashing.org> Thu, 05 Jan 2006 09:33:44 -0600

 drivers/net/gianfar_mii.c   |    5 ++++-
 include/linux/fsl_devices.h |    3 ---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index 04a462c..74e52fc 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -128,6 +128,7 @@ int gfar_mdio_probe(struct device *dev)
 	struct gianfar_mdio_data *pdata;
 	struct gfar_mii *regs;
 	struct mii_bus *new_bus;
+	struct resource *r;
 	int err = 0;
 
 	if (NULL == dev)
@@ -151,8 +152,10 @@ int gfar_mdio_probe(struct device *dev)
 		return -ENODEV;
 	}
 
+	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+
 	/* Set the PHY base address */
-	regs = (struct gfar_mii *) ioremap(pdata->paddr, 
+	regs = (struct gfar_mii *) ioremap(r->start,
 			sizeof (struct gfar_mii));
 
 	if (NULL == regs) {
diff --git a/include/linux/fsl_devices.h b/include/linux/fsl_devices.h
index 934aa9b..a7a2b85 100644
--- a/include/linux/fsl_devices.h
+++ b/include/linux/fsl_devices.h
@@ -55,9 +55,6 @@ struct gianfar_platform_data {
 };
 
 struct gianfar_mdio_data {
-	/* device specific information */
-	u32 paddr;
-
 	/* board specific information */
 	int irq[32];
 };

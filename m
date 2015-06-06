From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] wan: dscc4: fix build warning Wunused-but-set-variable
Date: Sat,  6 Jun 2015 10:41:17 +0200
Message-ID: <1433580077-1271-1-git-send-email-hofrat@osadl.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix:
drivers/net/wan/dscc4.c: In function 'dscc4_open':
drivers/net/wan/dscc4.c:1049:25: warning: variable 'ppriv' set but not used
[-Wunused-but-set-variable]

This has been in there unused since 1da177e4c3f (Linux-2.6.12-rc2) simply
remove it.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Was not able to trace when this got put in and why - but if nobody noticed
this within 10 years it probably really is dead code.

Patch was compile tested with x86_64_defconfig + CONFIG_WAN=y
CONFIG_HDLC=m, CONFIG_DSCC4=m

Patch is against 4.1-rc6 (localversion-next is -next-20150605)

 drivers/net/wan/dscc4.c |    3 ---
 1 file changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 0822356..2ce5249 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -1046,7 +1046,6 @@ static void dscc4_pci_reset(struct pci_dev *pdev, void __iomem *ioaddr)
 static int dscc4_open(struct net_device *dev)
 {
 	struct dscc4_dev_priv *dpriv = dscc4_priv(dev);
-	struct dscc4_pci_priv *ppriv;
 	int ret = -EAGAIN;
 
 	if ((dscc4_loopback_check(dpriv) < 0))
@@ -1055,8 +1054,6 @@ static int dscc4_open(struct net_device *dev)
 	if ((ret = hdlc_open(dev)))
 		goto err;
 
-	ppriv = dpriv->pci_priv;
-
 	/*
 	 * Due to various bugs, there is no way to reliably reset a
 	 * specific port (manufacturer's dependent special PCI #RST wiring
-- 
1.7.10.4

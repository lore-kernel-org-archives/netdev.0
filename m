From: Jeff Garzik <jeff@garzik.org>
Subject: [git patch] net driver fix
Date: Sat, 25 Feb 2006 17:03:03 -0500
Message-ID: <20060225220303.GA27133@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750891AbWBYWDM@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git

to receive the following updates:

 drivers/net/sis900.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Daniele Venzano:
      Fix Wake on LAN support in sis900

diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 3d95fa2..7a952fe 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -540,7 +540,7 @@ static int __devinit sis900_probe(struct
 	printk("%2.2x.\n", net_dev->dev_addr[i]);
 
 	/* Detect Wake on Lan support */
-	ret = inl(CFGPMC & PMESP);
+	ret = (inl(net_dev->base_addr + CFGPMC) & PMESP) >> 27;
 	if (netif_msg_probe(sis_priv) && (ret & PME_D3C) == 0)
 		printk(KERN_INFO "%s: Wake on LAN only available from suspend to RAM.", net_dev->name);
 
@@ -2040,7 +2040,7 @@ static int sis900_set_wol(struct net_dev
 
 	if (wol->wolopts == 0) {
 		pci_read_config_dword(sis_priv->pci_dev, CFGPMCSR, &cfgpmcsr);
-		cfgpmcsr |= ~PME_EN;
+		cfgpmcsr &= ~PME_EN;
 		pci_write_config_dword(sis_priv->pci_dev, CFGPMCSR, cfgpmcsr);
 		outl(pmctrl_bits, pmctrl_addr);
 		if (netif_msg_wol(sis_priv))

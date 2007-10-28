From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 00/04] pull request for 'upstream-jeff' branch
Date: Sun, 28 Oct 2007 18:19:37 +0100
Message-ID: <20071028171937.GA24622@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39580 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751312AbXJ1R0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 13:26:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from branch 'upstream-jeff' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git upstream-jeff

to get the changes below.

Distance from 'master' (96fd4cd3e40e240f0c385af87f58e74da8b7099a)
-----------------------------------------------------------------

d1417862d7355f0b395d83f2884afd614b086695
bbd82f956e0db6190b16a8a00d3ed5d979f488e8
93dd79e87bbc98ef02610d54fe72d4a1931ee15e
7fab06c0ca89d99442a4baeddf417add585e2672

Diffstat
--------

 drivers/net/Kconfig |   13 +++++++------
 drivers/net/r8169.c |   12 ++++++------
 2 files changed, 13 insertions(+), 12 deletions(-)

Shortlog
--------

Francois Romieu (2):
      ipg: missing Kconfig dependency
      ipg: Kconfig whitepaces/tab damages

Stephen Hemminger (2):
      r8169: napi config
      r8169: remove poll_locked logic

Patch
-----

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 86b8641..72d3447 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -166,13 +166,14 @@ config NET_SB1000
 	  If you don't have this card, of course say N.
 
 config IP1000
-       tristate "IP1000 Gigabit Ethernet support"
-       depends on PCI && EXPERIMENTAL
-       ---help---
-         This driver supports IP1000 gigabit Ethernet cards.
+	tristate "IP1000 Gigabit Ethernet support"
+	depends on PCI && EXPERIMENTAL
+	select MII
+	---help---
+	  This driver supports IP1000 gigabit Ethernet cards.
 
-         To compile this driver as a module, choose M here: the module
-         will be called ipg.  This is recommended.
+	  To compile this driver as a module, choose M here: the module
+	  will be called ipg.  This is recommended.
 
 source "drivers/net/arcnet/Kconfig"
 
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index e8960f2..b94fa7e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -392,7 +392,9 @@ struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
 	struct pci_dev *pci_dev;	/* Index of PCI device */
 	struct net_device *dev;
+#ifdef CONFIG_R8169_NAPI
 	struct napi_struct napi;
+#endif
 	spinlock_t lock;		/* spin lock flag */
 	u32 msg_enable;
 	int chipset;
@@ -2989,13 +2991,16 @@ static void rtl8169_down(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned int poll_locked = 0;
 	unsigned int intrmask;
 
 	rtl8169_delete_timer(dev);
 
 	netif_stop_queue(dev);
 
+#ifdef CONFIG_R8169_NAPI
+	napi_disable(&tp->napi);
+#endif
+
 core_down:
 	spin_lock_irq(&tp->lock);
 
@@ -3009,11 +3014,6 @@ core_down:
 
 	synchronize_irq(dev->irq);
 
-	if (!poll_locked) {
-		napi_disable(&tp->napi);
-		poll_locked++;
-	}
-
 	/* Give a racing hard_start_xmit a few cycles to complete. */
 	synchronize_sched();  /* FIXME: should this be synchronize_irq()? */
 
-- 
Ueimor

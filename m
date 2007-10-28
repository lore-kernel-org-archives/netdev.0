From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 01/04] r8169: napi config
Date: Sun, 28 Oct 2007 18:21:08 +0100
Message-ID: <20071028172108.GB24622@electric-eye.fr.zoreil.com>
References: <20071028171937.GA24622@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:39591 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752133AbXJ1R1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 13:27:32 -0400
Content-Disposition: inline
In-Reply-To: <20071028171937.GA24622@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't call napi_disable if not configured and make sure that any
misuse of napi_xxx in future fails with a compile error.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index e8960f2..c5eaf49 100644
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
@@ -3010,7 +3012,9 @@ core_down:
 	synchronize_irq(dev->irq);
 
 	if (!poll_locked) {
+#ifdef CONFIG_R8169_NAPI
 		napi_disable(&tp->napi);
+#endif
 		poll_locked++;
 	}
 
-- 
1.5.2.4


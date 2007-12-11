From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] drivers/net/s2io.c section fixes
Date: Tue, 11 Dec 2007 23:23:06 +0100
Message-ID: <20071211222306.GV14204@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ram.vepa@neterion.com, santosh.rastapur@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:38532 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755928AbXLKWXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 17:23:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code used by the non-__devinit s2io_open() mustn't be __devinit.

This patch fixes the following section mismatch with CONFIG_HOTPLUG=n:

<--  snip  -->

...
WARNING: vmlinux.o(.text+0x6f6e3e): Section mismatch: reference to .init.text.20:s2io_test_intr (between 's2io_open' and 's2io_ethtool_sset')
...

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/s2io.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

50fb761b99d7ee0b234359d02144f84a87e2faff 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 121cb10..9d80f1c 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3737,7 +3737,7 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 }
 
 /* Handle software interrupt used during MSI(X) test */
-static irqreturn_t __devinit s2io_test_intr(int irq, void *dev_id)
+static irqreturn_t s2io_test_intr(int irq, void *dev_id)
 {
 	struct s2io_nic *sp = dev_id;
 
@@ -3748,7 +3748,7 @@ static irqreturn_t __devinit s2io_test_intr(int irq, void *dev_id)
 }
 
 /* Test interrupt path by forcing a a software IRQ */
-static int __devinit s2io_test_msi(struct s2io_nic *sp)
+static int s2io_test_msi(struct s2io_nic *sp)
 {
 	struct pci_dev *pdev = sp->pdev;
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;

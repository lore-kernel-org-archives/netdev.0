From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 07/18 v2] isdn: avm: call disable_pci_device() if pci_probe() failed
Date: Mon,  9 Aug 2010 23:50:47 +0400
Message-ID: <1281383448-14050-1-git-send-email-segooon@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:35224 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755218Ab0HITuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 15:50:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver should call disable_pci_device() if it returns from pci_probe()
with error.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/isdn/hardware/avm/t1pci.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/hardware/avm/t1pci.c b/drivers/isdn/hardware/avm/t1pci.c
index 5a3f830..a79eb5a 100644
--- a/drivers/isdn/hardware/avm/t1pci.c
+++ b/drivers/isdn/hardware/avm/t1pci.c
@@ -210,6 +210,7 @@ static int __devinit t1pci_probe(struct pci_dev *dev,
 	if (retval != 0) {
 		printk(KERN_ERR "t1pci: no AVM-T1-PCI at i/o %#x, irq %d detected, mem %#x\n",
 		       param.port, param.irq, param.membase);
+		pci_disable_device(dev);
 		return -ENODEV;
 	}
 	return 0;
-- 
1.7.0.4


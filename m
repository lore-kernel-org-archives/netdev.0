From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 06/18 v2] isdn: avm: call disable_pci_device() if pci_probe() failed
Date: Mon,  9 Aug 2010 23:50:37 +0400
Message-ID: <1281383439-13988-1-git-send-email-segooon@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Tilman Schmidt <tilman@imap.cc>, Tejun Heo <tj@kernel.org>,
	netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:35224 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754325Ab0HITus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 15:50:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver should call disable_pci_device() if it returns from pci_probe()
with error.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/isdn/hardware/avm/c4.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/hardware/avm/c4.c b/drivers/isdn/hardware/avm/c4.c
index 7715d32..d3530f6 100644
--- a/drivers/isdn/hardware/avm/c4.c
+++ b/drivers/isdn/hardware/avm/c4.c
@@ -1273,6 +1273,7 @@ static int __devinit c4_probe(struct pci_dev *dev,
 	if (retval != 0) {
 		printk(KERN_ERR "c4: no AVM-C%d at i/o %#x, irq %d detected, mem %#x\n",
 		       nr, param.port, param.irq, param.membase);
+		pci_disable_device(dev);
 		return -ENODEV;
 	}
 	return 0;
-- 
1.7.0.4


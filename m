From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] atm: solos-pci: remove useless variable assignments
Date: Thu, 15 Jun 2017 14:56:21 -0500
Message-ID: <20170615195621.GA5600@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Chas Williams <3chas3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway30.websitewelcome.com ([192.185.146.7]:32680 "EHLO
        gateway30.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751711AbdFOT4Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 15:56:25 -0400
Received: from cm12.websitewelcome.com (cm12.websitewelcome.com [100.42.49.8])
        by gateway30.websitewelcome.com (Postfix) with ESMTP id 00A3D13459
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 14:56:23 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Value assigned to variable _data32_ at lines 1254 and 1257 is
overwritten at line 1260 before it can be used. This makes
such variable assignments useless.

Addresses-Coverity-ID: 1227049
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/atm/solos-pci.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 5ad037c..9115b29 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1251,10 +1251,10 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 
 	if (reset) {
 		iowrite32(1, card->config_regs + FPGA_MODE);
-		data32 = ioread32(card->config_regs + FPGA_MODE); 
+		ioread32(card->config_regs + FPGA_MODE);
 
 		iowrite32(0, card->config_regs + FPGA_MODE);
-		data32 = ioread32(card->config_regs + FPGA_MODE); 
+		ioread32(card->config_regs + FPGA_MODE);
 	}
 
 	data32 = ioread32(card->config_regs + FPGA_VER);
-- 
2.5.0

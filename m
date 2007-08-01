From: maximilian attems <max@stro.at>
Subject: [patch] sis190 check for ISA bridge on SiS966
Date: Wed, 1 Aug 2007 17:52:04 +0200
Message-ID: <20070801155204.GB21942@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Neil Muller <drnlmuller+bugs@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:3370 "EHLO baikonur.stro.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758000AbXHAPyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 11:54:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Muller <drnlmuller+bugs@gmail.com>

sis190 driver assumes to find ISA only on SiS965.
similar fix is in sis900 driver, see bug report
http://bugs.debian.org/435547

Signed-off-by: maximilian attems <max@stro.at>

---

 drivers/net/sis190.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index ec2ad9f..d470b19 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1593,6 +1593,9 @@ static int __devinit sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
 		  pci_name(pdev));
 
 	isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, 0x0965, NULL);
+	if (!isa_bridge)
+		isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, 0x0966, NULL);
+
 	if (!isa_bridge) {
 		net_probe(tp, KERN_INFO "%s: Can not find ISA bridge.\n",
 			  pci_name(pdev));

-- 
maks

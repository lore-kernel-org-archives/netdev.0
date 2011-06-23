From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] ssb: use pci_dev->revision
Date: Thu, 23 Jun 2011 18:49:52 +0400
Message-ID: <201106231849.53030.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: mb@bu3sch.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:39479 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1759225Ab1FWOvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 10:51:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bus scan code reads PCI revision ID from the PCI configuration register
while it's already stored by PCI subsystem in the 'revision' field of 'struct
pci_dev'...

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
The patch is against the recent Linus' tree.

There's another place where the revision ID register is read but as 16-bit
entity (probably by mistake though), so I didn't convert it...

 drivers/ssb/scan.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: linux-2.6/drivers/ssb/scan.c
===================================================================
--- linux-2.6.orig/drivers/ssb/scan.c
+++ linux-2.6/drivers/ssb/scan.c
@@ -310,8 +310,7 @@ int ssb_bus_scan(struct ssb_bus *bus,
 	} else {
 		if (bus->bustype == SSB_BUSTYPE_PCI) {
 			bus->chip_id = pcidev_to_chipid(bus->host_pci);
-			pci_read_config_byte(bus->host_pci, PCI_REVISION_ID,
-					     &bus->chip_rev);
+			bus->chip_rev = bus->host_pci->revision;
 			bus->chip_package = 0;
 		} else {
 			bus->chip_id = 0x4710;

From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH 2/3 v2] ssb: use pci_dev->revision
Date: Fri, 1 Jul 2011 22:33:08 +0400
Message-ID: <201107012233.08489.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: mb@bu3sch.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:47196 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753679Ab1GASew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 14:34:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SSB code reads PCI revision ID from the PCI configuration register while
it's already stored by the PCI subsystem in the 'revision' field  of 'struct
pci_dev'...

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
The patch is against the recent Linus' tree.

 drivers/ssb/pci.c  |    3 +--
 drivers/ssb/scan.c |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/ssb/pci.c
===================================================================
--- linux-2.6.orig/drivers/ssb/pci.c
+++ linux-2.6/drivers/ssb/pci.c
@@ -738,8 +738,7 @@ static void ssb_pci_get_boardinfo(struct
 			     &bi->vendor);
 	pci_read_config_word(bus->host_pci, PCI_SUBSYSTEM_ID,
 			     &bi->type);
-	pci_read_config_byte(bus->host_pci, PCI_REVISION_ID,
-			     &bi->rev);
+	bi->rev = bus->host_pci->revision;
 }
 
 int ssb_pci_get_invariants(struct ssb_bus *bus,
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

From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH 3/3 v2] ssb: use pci_dev->subsystem_{vendor,device}
Date: Fri, 1 Jul 2011 22:34:42 +0400
Message-ID: <201107012234.42426.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: mb@bu3sch.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:47198 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753679Ab1GASg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 14:36:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SSB code reads PCI subsystem IDs from the PCI configuration registers while
they are already stored by the PCI subsystem in the 'subsystem_{vendor|device}'
fields of 'struct pci_dev'...

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---
The patch is against the recent Linus' tree.

 drivers/ssb/pci.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/ssb/pci.c
===================================================================
--- linux-2.6.orig/drivers/ssb/pci.c
+++ linux-2.6/drivers/ssb/pci.c
@@ -734,10 +734,8 @@ out_free:
 static void ssb_pci_get_boardinfo(struct ssb_bus *bus,
 				  struct ssb_boardinfo *bi)
 {
-	pci_read_config_word(bus->host_pci, PCI_SUBSYSTEM_VENDOR_ID,
-			     &bi->vendor);
-	pci_read_config_word(bus->host_pci, PCI_SUBSYSTEM_ID,
-			     &bi->type);
+	bi->vendor = bus->host_pci->subsystem_vendor;
+	bi->type = bus->host_pci->subsystem_device;
 	bi->rev = bus->host_pci->revision;
 }
 

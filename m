From: domen@coderock.org
Subject: [patch 09/26] janitor: net/gt96100eth: pci_find_device to pci_get_device
Date: Sun, 06 Mar 2005 11:33:04 +0100
Message-ID: <20050306103305.5110C1F1F0@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, sfeldma@pobox.com,
        janitor@sternwelten.at
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Replace pci_find_device with pci_get_device/pci_dev_put to plug
race with pci_find_device.

Signed-off-by: Scott Feldman <sfeldma@pobox.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/gt96100eth.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/net/gt96100eth.c~remove-pci-find-device-drivers_net_gt96100eth drivers/net/gt96100eth.c
--- kj/drivers/net/gt96100eth.c~remove-pci-find-device-drivers_net_gt96100eth	2005-03-05 16:09:43.000000000 +0100
+++ kj-domen/drivers/net/gt96100eth.c	2005-03-05 16:09:43.000000000 +0100
@@ -615,9 +615,9 @@ static int gt96100_init_module(void)
 	/*
 	 * Stupid probe because this really isn't a PCI device
 	 */
-	if (!(pci = pci_find_device(PCI_VENDOR_ID_MARVELL,
+	if (!(pci = pci_get_device(PCI_VENDOR_ID_MARVELL,
 	                            PCI_DEVICE_ID_MARVELL_GT96100, NULL)) &&
-	    !(pci = pci_find_device(PCI_VENDOR_ID_MARVELL,
+	    !(pci = pci_get_device(PCI_VENDOR_ID_MARVELL,
 		                    PCI_DEVICE_ID_MARVELL_GT96100A, NULL))) {
 		printk(KERN_ERR __FILE__ ": GT96100 not found!\n");
 		return -ENODEV;
@@ -627,12 +627,14 @@ static int gt96100_init_module(void)
 	if (cpuConfig & (1<<12)) {
 		printk(KERN_ERR __FILE__
 		       ": must be in Big Endian mode!\n");
+		pci_dev_put(pci);
 		return -ENODEV;
 	}
 
 	for (i=0; i < NUM_INTERFACES; i++)
 		retval |= gt96100_probe1(pci, i);
 
+	pci_dev_put(pci);
 	return retval;
 }
 
_

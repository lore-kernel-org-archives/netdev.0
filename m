From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the pci tree
Date: Wed, 12 Apr 2017 10:25:22 +1000
Message-ID: <20170412102522.50b92f74@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Bjorn Helgaas <bhelgaas@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:60005 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752290AbdDLAZY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 20:25:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the net-next tree got conflicts in:

  drivers/pci/msi.c
  include/linux/pci.h

between commit:

  688769f643bf ("PCI/MSI: Make pci_msi_shutdown() and pci_msix_shutdown() static")

from the pci tree and commit:

  4244de1c64de ("PCI: remove pci_enable_msix")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/pci/msi.c
index 6b5eaf500a24,0042c365b29b..000000000000
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@@ -975,28 -973,7 +975,7 @@@ static int __pci_enable_msix(struct pci
  	return msix_capability_init(dev, entries, nvec, affd);
  }
  
- /**
-  * pci_enable_msix - configure device's MSI-X capability structure
-  * @dev: pointer to the pci_dev data structure of MSI-X device function
-  * @entries: pointer to an array of MSI-X entries (optional)
-  * @nvec: number of MSI-X irqs requested for allocation by device driver
-  *
-  * Setup the MSI-X capability structure of device function with the number
-  * of requested irqs upon its software driver call to request for
-  * MSI-X mode enabled on its hardware device function. A return of zero
-  * indicates the successful configuration of MSI-X capability structure
-  * with new allocated MSI-X irqs. A return of < 0 indicates a failure.
-  * Or a return of > 0 indicates that driver request is exceeding the number
-  * of irqs or MSI-X vectors available. Driver should use the returned value to
-  * re-send its request.
-  **/
- int pci_enable_msix(struct pci_dev *dev, struct msix_entry *entries, int nvec)
- {
- 	return __pci_enable_msix(dev, entries, nvec, NULL);
- }
- EXPORT_SYMBOL(pci_enable_msix);
- 
 -void pci_msix_shutdown(struct pci_dev *dev)
 +static void pci_msix_shutdown(struct pci_dev *dev)
  {
  	struct msi_desc *entry;
  
diff --cc include/linux/pci.h
index 821627873de1,82dec36845e6..000000000000
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@@ -1279,9 -1297,10 +1279,8 @@@ struct msix_entry 
  
  #ifdef CONFIG_PCI_MSI
  int pci_msi_vec_count(struct pci_dev *dev);
 -void pci_msi_shutdown(struct pci_dev *dev);
  void pci_disable_msi(struct pci_dev *dev);
  int pci_msix_vec_count(struct pci_dev *dev);
- int pci_enable_msix(struct pci_dev *dev, struct msix_entry *entries, int nvec);
 -void pci_msix_shutdown(struct pci_dev *dev);
  void pci_disable_msix(struct pci_dev *dev);
  void pci_restore_msi_state(struct pci_dev *dev);
  int pci_msi_enabled(void);
@@@ -1307,11 -1326,10 +1306,8 @@@ int pci_irq_get_node(struct pci_dev *pd
  
  #else
  static inline int pci_msi_vec_count(struct pci_dev *dev) { return -ENOSYS; }
 -static inline void pci_msi_shutdown(struct pci_dev *dev) { }
  static inline void pci_disable_msi(struct pci_dev *dev) { }
  static inline int pci_msix_vec_count(struct pci_dev *dev) { return -ENOSYS; }
- static inline int pci_enable_msix(struct pci_dev *dev,
- 				  struct msix_entry *entries, int nvec)
- { return -ENOSYS; }
 -static inline void pci_msix_shutdown(struct pci_dev *dev) { }
  static inline void pci_disable_msix(struct pci_dev *dev) { }
  static inline void pci_restore_msi_state(struct pci_dev *dev) { }
  static inline int pci_msi_enabled(void) { return 0; }

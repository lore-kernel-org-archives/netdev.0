From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Fri, 19 Oct 2007 14:36:56 -0700
Message-ID: <1192829817.22064.559.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz,
	"Linas Vepstas" <linas@austin.ibm.com>,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3172 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935930AbXJSVhS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 17:37:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch exports the pci_restore_msi_state() function.  This function
is needed to restore the MSI state during PCI error recovery.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index 87e0161..f57762d 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -224,7 +224,6 @@ static struct msi_desc* alloc_msi_entry(void)
 	return entry;
 }
 
-#ifdef CONFIG_PM
 static void __pci_restore_msi_state(struct pci_dev *dev)
 {
 	int pos;
@@ -282,7 +281,7 @@ void pci_restore_msi_state(struct pci_dev *dev)
 	__pci_restore_msi_state(dev);
 	__pci_restore_msix_state(dev);
 }
-#endif	/* CONFIG_PM */
+EXPORT_SYMBOL_GPL(pci_restore_msi_state);
 
 /**
  * msi_capability_init - configure device's MSI capability structure
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index 6fda33d..23c6c17 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -45,12 +45,6 @@ static inline void pci_no_msi(void) { }
 static inline void pci_msi_init_pci_dev(struct pci_dev *dev) { }
 #endif
 
-#if defined(CONFIG_PCI_MSI) && defined(CONFIG_PM)
-void pci_restore_msi_state(struct pci_dev *dev);
-#else
-static inline void pci_restore_msi_state(struct pci_dev *dev) {}
-#endif
-
 #ifdef CONFIG_PCIEAER
 void pci_no_aer(void);
 #else
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 768b933..5575227 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -662,6 +662,7 @@ static inline int pci_enable_msix(struct pci_dev* dev,
 	struct msix_entry *entries, int nvec) {return -1;}
 static inline void pci_disable_msix(struct pci_dev *dev) {}
 static inline void msi_remove_pci_irq_vectors(struct pci_dev *dev) {}
+static inline void pci_restore_msi_state(struct pci_dev *dev) {}
 #else
 extern int pci_enable_msi(struct pci_dev *dev);
 extern void pci_disable_msi(struct pci_dev *dev);
@@ -669,6 +670,7 @@ extern int pci_enable_msix(struct pci_dev* dev,
 	struct msix_entry *entries, int nvec);
 extern void pci_disable_msix(struct pci_dev *dev);
 extern void msi_remove_pci_irq_vectors(struct pci_dev *dev);
+void pci_restore_msi_state(struct pci_dev *dev);
 #endif
 
 #ifdef CONFIG_HT_IRQ



From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next (repost)] nfp: Use PCI_DEVICE_ID_NETRONOME_NFP* defines
Date: Fri, 17 Feb 2017 08:57:54 +0100
Message-ID: <1487318274-17216-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35185 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753622AbdBQH6G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 02:58:06 -0500
Received: by mail-wm0-f44.google.com with SMTP id v186so7111286wmd.0
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 23:58:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use PCI_DEVICE_ID_NETRONOME_NFP*, defined in linux/pci_ids.h,
rather than replicating the same values in the NFP driver.

Signed-off-by: Simon Horman <simon.horman@netronome.com>

---
* Reposted with subject and changelog adjusted to be less likely to be
  flagged as spam
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c             | 4 ++--
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c | 4 ++--
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h      | 5 -----
 3 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index 6e1bb3a4a611..db52b6a53c6f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -58,11 +58,11 @@ static const char nfp_driver_name[] = "nfp";
 const char nfp_driver_version[] = VERMAGIC_STRING;
 
 static const struct pci_device_id nfp_pci_device_ids[] = {
-	{ PCI_VENDOR_ID_NETRONOME, PCI_DEVICE_NFP6000,
+	{ PCI_VENDOR_ID_NETRONOME, PCI_DEVICE_ID_NETRONOME_NFP6000,
 	  PCI_VENDOR_ID_NETRONOME, PCI_ANY_ID,
 	  PCI_ANY_ID, 0,
 	},
-	{ PCI_VENDOR_ID_NETRONOME, PCI_DEVICE_NFP4000,
+	{ PCI_VENDOR_ID_NETRONOME, PCI_DEVICE_ID_NETRONOME_NFP4000,
 	  PCI_VENDOR_ID_NETRONOME, PCI_ANY_ID,
 	  PCI_ANY_ID, 0,
 	},
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
index 165e085c2a24..15cc3e77cf6a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
@@ -640,8 +640,8 @@ static int enable_bars(struct nfp6000_pcie *nfp, u16 interface)
 		nfp->expl.data = bar->iomem + NFP_PCIE_SRAM + 0x1000;
 	}
 
-	if (nfp->pdev->device == PCI_DEVICE_NFP4000 ||
-	    nfp->pdev->device == PCI_DEVICE_NFP6000) {
+	if (nfp->pdev->device == PCI_DEVICE_ID_NETRONOME_NFP4000 ||
+	    nfp->pdev->device == PCI_DEVICE_ID_NETRONOME_NFP6000) {
 		nfp->iomem.csr = bar->iomem + NFP_PCIE_BAR(0);
 		expl_groups = 4;
 	} else {
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
index 74e6f9f59bdc..edecc0a27485 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h
@@ -58,11 +58,6 @@
 
 #define PCI_64BIT_BAR_COUNT             3
 
-/* NFP hardware vendor/device ids.
- */
-#define PCI_DEVICE_NFP4000              0x4000
-#define PCI_DEVICE_NFP6000              0x6000
-
 #define NFP_CPP_NUM_TARGETS             16
 
 struct device;
-- 
2.7.0.rc3.207.g0ac5344

From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 01/77] PCI/MSI: Fix return value when populate_msi_sysfs() failed
Date: Wed,  2 Oct 2013 12:48:17 +0200
Message-ID: <3ff5236944aae69f2cd934b5b6da7c1c269df7c1.1380703262.git.agordeev@redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
        Matt Porter <mporter@kernel.crashing.org>,
        stable@vger.kernel.org, linux-pci@vger.kernel.org,
        linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org,
        linux390@de.ibm.com, linux-s390@vger.kernel.org, x86@kernel.org,
        linux-ide@vger.kernel.org, iss_storagedev@hp.com,
        linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, e1000-de
To: linux-kernel@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <cover.1380703262.git.agordeev@redhat.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/pci/msi.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index d5f90d6..b43f391 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -719,7 +719,7 @@ static int msix_capability_init(struct pci_dev *dev,
 
 	ret = arch_setup_msi_irqs(dev, nvec, PCI_CAP_ID_MSIX);
 	if (ret)
-		goto error;
+		goto out_avail;
 
 	/*
 	 * Some devices require MSI-X to be enabled before we can touch the
@@ -732,10 +732,8 @@ static int msix_capability_init(struct pci_dev *dev,
 	msix_program_entries(dev, entries);
 
 	ret = populate_msi_sysfs(dev);
-	if (ret) {
-		ret = 0;
-		goto error;
-	}
+	if (ret)
+		goto out_free;
 
 	/* Set MSI-X enabled bits and unmask the function */
 	pci_intx_for_msi(dev, 0);
@@ -746,7 +744,7 @@ static int msix_capability_init(struct pci_dev *dev,
 
 	return 0;
 
-error:
+out_avail:
 	if (ret < 0) {
 		/*
 		 * If we had some success, report the number of irqs
@@ -763,6 +761,7 @@ error:
 			ret = avail;
 	}
 
+out_free:
 	free_msi_irqs(dev);
 
 	return ret;
-- 
1.7.7.6

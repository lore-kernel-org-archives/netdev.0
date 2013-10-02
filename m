From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 03/77] PCI/MSI/s390: Fix single MSI only check
Date: Wed,  2 Oct 2013 12:48:19 +0200
Message-ID: <8c9811b13fd93e73641dab8e3bd1bd5b2dc37a61.1380703262.git.agordeev@redhat.com>
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

Multiple MSIs have never been supported on s390 architecture,
but the platform code fails to report single MSI only.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 arch/s390/pci/pci.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/s390/pci/pci.c b/arch/s390/pci/pci.c
index f17a834..c79c6e4 100644
--- a/arch/s390/pci/pci.c
+++ b/arch/s390/pci/pci.c
@@ -427,6 +427,8 @@ int arch_setup_msi_irqs(struct pci_dev *pdev, int nvec, int type)
 	pr_debug("%s: requesting %d MSI-X interrupts...", __func__, nvec);
 	if (type != PCI_CAP_ID_MSIX && type != PCI_CAP_ID_MSI)
 		return -EINVAL;
+	if (type == PCI_CAP_ID_MSI && nvec > 1)
+		return 1;
 	msi_vecs = min(nvec, ZPCI_MSI_VEC_MAX);
 	msi_vecs = min_t(unsigned int, msi_vecs, CONFIG_PCI_NR_MSI);
 
-- 
1.7.7.6

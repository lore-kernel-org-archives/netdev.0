From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 18/77] cciss: Fallback to single MSI mode in case MSI-X failed
Date: Wed,  2 Oct 2013 12:48:34 +0200
Message-ID: <a0fa5fa4243512602a9ef71a81dec396d6d3d00e.1380703262.git.agordeev@redhat.com>
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
 drivers/block/cciss.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/block/cciss.c b/drivers/block/cciss.c
index bf11540..0eea035 100644
--- a/drivers/block/cciss.c
+++ b/drivers/block/cciss.c
@@ -4081,7 +4081,7 @@ static void cciss_interrupt_mode(ctlr_info_t *h)
 	if (pci_find_capability(h->pdev, PCI_CAP_ID_MSIX)) {
 		err = pci_msix_table_size(h->pdev);
 		if (err < ARRAY_SIZE(cciss_msix_entries))
-			goto default_int_mode;
+			goto single_msi_mode;
 		err = pci_enable_msix(h->pdev, cciss_msix_entries,
 				      ARRAY_SIZE(cciss_msix_entries));
 		if (!err) {
@@ -4093,8 +4093,8 @@ static void cciss_interrupt_mode(ctlr_info_t *h)
 			return;
 		}
 		dev_warn(&h->pdev->dev, "MSI-X init failed %d\n", err);
-		goto default_int_mode;
 	}
+single_msi_mode:
 	if (pci_find_capability(h->pdev, PCI_CAP_ID_MSI)) {
 		if (!pci_enable_msi(h->pdev))
 			h->msi_vector = 1;
-- 
1.7.7.6

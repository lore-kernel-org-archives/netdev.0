From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 32/77] hpsa: Fallback to single MSI mode in case MSI-X failed
Date: Wed,  2 Oct 2013 12:48:48 +0200
Message-ID: <a8343fb00f8dfdcb637913b5a691dcea7ecffffc.1380703263.git.agordeev@redhat.com>
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
 drivers/scsi/hpsa.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/scsi/hpsa.c b/drivers/scsi/hpsa.c
index eb17b3d..252b65d 100644
--- a/drivers/scsi/hpsa.c
+++ b/drivers/scsi/hpsa.c
@@ -4112,7 +4112,7 @@ static void hpsa_interrupt_mode(struct ctlr_info *h)
 
 		err = pci_msix_table_size(h->pdev);
 		if (err < ARRAY_SIZE(hpsa_msix_entries))
-			goto default_int_mode;
+			goto single_msi_mode;
 
 		for (i = 0; i < ARRAY_SIZE(hpsa_msix_entries); i++) {
 			hpsa_msix_entries[i].vector = 0;
@@ -4128,8 +4128,9 @@ static void hpsa_interrupt_mode(struct ctlr_info *h)
 			return;
 		}
 		dev_warn(&h->pdev->dev, "MSI-X init failed %d\n", err);
-		goto default_int_mode;
+		goto single_msi_mode;
 	}
+single_msi_mode:
 	if (pci_find_capability(h->pdev, PCI_CAP_ID_MSI)) {
 		dev_info(&h->pdev->dev, "MSI\n");
 		if (!pci_enable_msi(h->pdev))
-- 
1.7.7.6

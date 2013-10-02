From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 41/77] lpfc: Do not call pci_disable_msix() if pci_enable_msix() failed
Date: Wed,  2 Oct 2013 12:48:57 +0200
Message-ID: <8e18482bc1c22d1764a743f053909c348d7acdec.1380703263.git.agordeev@redhat.com>
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
 drivers/scsi/lpfc/lpfc_init.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/scsi/lpfc/lpfc_init.c b/drivers/scsi/lpfc/lpfc_init.c
index 647f5bf..0803b84 100644
--- a/drivers/scsi/lpfc/lpfc_init.c
+++ b/drivers/scsi/lpfc/lpfc_init.c
@@ -8080,7 +8080,7 @@ lpfc_sli_enable_msix(struct lpfc_hba *phba)
 	if (rc) {
 		lpfc_printf_log(phba, KERN_INFO, LOG_INIT,
 				"0420 PCI enable MSI-X failed (%d)\n", rc);
-		goto msi_fail_out;
+		goto vec_fail_out;
 	}
 	for (i = 0; i < LPFC_MSIX_VECTORS; i++)
 		lpfc_printf_log(phba, KERN_INFO, LOG_INIT,
@@ -8158,6 +8158,8 @@ irq_fail_out:
 msi_fail_out:
 	/* Unconfigure MSI-X capability structure */
 	pci_disable_msix(phba->pcidev);
+
+vec_fail_out:
 	return rc;
 }
 
@@ -8646,7 +8648,7 @@ enable_msix_vectors:
 	} else if (rc) {
 		lpfc_printf_log(phba, KERN_INFO, LOG_INIT,
 				"0484 PCI enable MSI-X failed (%d)\n", rc);
-		goto msi_fail_out;
+		goto vec_fail_out;
 	}
 
 	/* Log MSI-X vector assignment */
@@ -8698,9 +8700,10 @@ cfg_fail_out:
 			 &phba->sli4_hba.fcp_eq_hdl[index]);
 	}
 
-msi_fail_out:
 	/* Unconfigure MSI-X capability structure */
 	pci_disable_msix(phba->pcidev);
+
+vec_fail_out:
 	return rc;
 }
 
-- 
1.7.7.6

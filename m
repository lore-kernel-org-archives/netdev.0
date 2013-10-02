From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 73/77] vmxnet3: Return -ENOSPC when not enough MSI-X vectors available
Date: Wed,  2 Oct 2013 12:49:29 +0200
Message-ID: <a24303b6fa85cfb01b4e1b6c67ff26825824d7f7.1380703263.git.agordeev@redhat.com>
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
 drivers/net/vmxnet3/vmxnet3_drv.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 3518173..3df7f32 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2752,7 +2752,10 @@ vmxnet3_acquire_msix_vectors(struct vmxnet3_adapter *adapter,
 				   "Failed to enable MSI-X, error: %d\n", err);
 			return err;
 		} else if (err < vector_threshold) {
-			break;
+			dev_info(&adapter->pdev->dev,
+				 "Number of MSI-Xs which can be allocated "
+				 "is lower than min threshold required.\n");
+			return -ENOSPC;
 		} else {
 			/* If fails to enable required number of MSI-x vectors
 			 * try enabling minimum number of vectors required.
@@ -2764,9 +2767,6 @@ vmxnet3_acquire_msix_vectors(struct vmxnet3_adapter *adapter,
 		}
 	}
 
-	dev_info(&adapter->pdev->dev,
-		 "Number of MSI-X interrupts which can be allocated "
-		 "is lower than min threshold required.\n");
 	return err;
 }
 
-- 
1.7.7.6

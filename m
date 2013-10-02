From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 20/77] csiostor: Return -ENOSPC when not enough MSI-X vectors available
Date: Wed,  2 Oct 2013 12:48:36 +0200
Message-ID: <db7d3fc15ca0d902ea354d0aa293416563c440c3.1380703262.git.agordeev@redhat.com>
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
 drivers/scsi/csiostor/csio_isr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/csiostor/csio_isr.c b/drivers/scsi/csiostor/csio_isr.c
index 91ba91d..abf20ab 100644
--- a/drivers/scsi/csiostor/csio_isr.c
+++ b/drivers/scsi/csiostor/csio_isr.c
@@ -533,7 +533,7 @@ csio_enable_msix(struct csio_hw *hw)
 			csio_info(hw, "Not using MSI-X, remainder:%d\n", rv);
 
 		kfree(entries);
-		return -ENOMEM;
+		return -ENOSPC;
 	}
 
 	/* Save off vectors */
-- 
1.7.7.6

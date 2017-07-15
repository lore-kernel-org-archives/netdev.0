From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 08/10] isdn: mISDN: avmfritz: constify pci_device_id.
Date: Sat, 15 Jul 2017 09:55:49 +0530
Message-ID: <1500092751-8291-9-git-send-email-arvind.yadav.cs@gmail.com>
References: <1500092751-8291-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: isdn@linux-pingi.de, davem@davemloft.net, dhowells@redhat.com,
        johannes.berg@intel.com, mac@melware.de, baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500092751-8291-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_device_id are not supposed to change at runtime. All functions
working with pci_device_id provided by <linux/pci.h> work with
const pci_device_id. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
   9963	   1936	     16	  11915	   2e8b	isdn/hardware/mISDN/avmfritz.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  10091	   1808	     16	  11915	   2e8b	isdn/hardware/mISDN/avmfritz.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/isdn/hardware/mISDN/avmfritz.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index e3fa1cd..dce6632 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -1142,7 +1142,7 @@ fritz_remove_pci(struct pci_dev *pdev)
 			pr_info("%s: drvdata already removed\n", __func__);
 }
 
-static struct pci_device_id fcpci_ids[] = {
+static const struct pci_device_id fcpci_ids[] = {
 	{ PCI_VENDOR_ID_AVM, PCI_DEVICE_ID_AVM_A1, PCI_ANY_ID, PCI_ANY_ID,
 	  0, 0, (unsigned long) "Fritz!Card PCI"},
 	{ PCI_VENDOR_ID_AVM, PCI_DEVICE_ID_AVM_A1_V2, PCI_ANY_ID, PCI_ANY_ID,
-- 
2.7.4

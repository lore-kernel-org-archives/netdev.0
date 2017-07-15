From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 05/10] isdn: mISDN: netjet: constify pci_device_id.
Date: Sat, 15 Jul 2017 09:55:46 +0530
Message-ID: <1500092751-8291-6-git-send-email-arvind.yadav.cs@gmail.com>
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
  10941	   1776	     16	  12733	   31bd isdn/hardware/mISDN/netjet.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  11005	   1712	     16	  12733	   31bd isdn/hardware/mISDN/netjet.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/isdn/hardware/mISDN/netjet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/mISDN/netjet.c b/drivers/isdn/hardware/mISDN/netjet.c
index afde4ed..6a6d848 100644
--- a/drivers/isdn/hardware/mISDN/netjet.c
+++ b/drivers/isdn/hardware/mISDN/netjet.c
@@ -1137,7 +1137,7 @@ static void nj_remove(struct pci_dev *pdev)
 /* We cannot select cards with PCI_SUB... IDs, since here are cards with
  * SUB IDs set to PCI_ANY_ID, so we need to match all and reject
  * known other cards which not work with this driver - see probe function */
-static struct pci_device_id nj_pci_ids[] = {
+static const struct pci_device_id nj_pci_ids[] = {
 	{ PCI_VENDOR_ID_TIGERJET, PCI_DEVICE_ID_TIGERJET_300,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{ }
-- 
2.7.4

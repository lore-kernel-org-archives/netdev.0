From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 11/12] atm: eni: constify pci_device_id.
Date: Sun, 16 Jul 2017 15:02:39 +0530
Message-ID: <1500197560-14623-12-git-send-email-arvind.yadav.cs@gmail.com>
References: <1500197560-14623-1-git-send-email-arvind.yadav.cs@gmail.com>
To: 3chas3@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-atm-general@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500197560-14623-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_device_id are not supposed to change at runtime. All functions
working with pci_device_id provided by <linux/pci.h> work with
const pci_device_id. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
  21565	    352	     56	  21973	   55d5	drivers/atm/eni.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  21661	    256	     56	  21973	   55d5	drivers/atm/eni.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/atm/eni.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index b042ec4..ce47eb1 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -2292,7 +2292,7 @@ static int eni_init_one(struct pci_dev *pci_dev,
 }
 
 
-static struct pci_device_id eni_pci_tbl[] = {
+static const struct pci_device_id eni_pci_tbl[] = {
 	{ PCI_VDEVICE(EF, PCI_DEVICE_ID_EF_ATM_FPGA), 0 /* FPGA */ },
 	{ PCI_VDEVICE(EF, PCI_DEVICE_ID_EF_ATM_ASIC), 1 /* ASIC */ },
 	{ 0, }
-- 
2.7.4

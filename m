From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 06/12] atm: horizon: constify pci_device_id.
Date: Sun, 16 Jul 2017 15:02:34 +0530
Message-ID: <1500197560-14623-7-git-send-email-arvind.yadav.cs@gmail.com>
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
   9859	    328	      6	  10193	   27d1	drivers/atm/horizon.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
   9923	    264	      6	  10193	   27d1	drivers/atm/horizon.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/atm/horizon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index 0f18480..7e76b35 100644
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -2867,7 +2867,7 @@ MODULE_PARM_DESC(max_tx_size, "maximum size of TX AAL5 frames");
 MODULE_PARM_DESC(max_rx_size, "maximum size of RX AAL5 frames");
 MODULE_PARM_DESC(pci_lat, "PCI latency in bus cycles");
 
-static struct pci_device_id hrz_pci_tbl[] = {
+static const struct pci_device_id hrz_pci_tbl[] = {
 	{ PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_HORIZON, PCI_ANY_ID, PCI_ANY_ID,
 	  0, 0, 0 },
 	{ 0, }
-- 
2.7.4

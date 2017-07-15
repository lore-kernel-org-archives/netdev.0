From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 01/10] isdn: hisax: constify pci_device_id.
Date: Sat, 15 Jul 2017 09:55:42 +0530
Message-ID: <1500092751-8291-2-git-send-email-arvind.yadav.cs@gmail.com>
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
  13686	   2064	   4416	  20166	   4ec6	drivers/isdn/hisax/config.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  15030	    720	   4416	  20166	   4ec6	drivers/isdn/hisax/config.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/isdn/hisax/config.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index c7d6867..7108bdb8 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -1909,7 +1909,7 @@ static void EChannel_proc_rcv(struct hisax_d_if *d_if)
 #ifdef CONFIG_PCI
 #include <linux/pci.h>
 
-static struct pci_device_id hisax_pci_tbl[] __used = {
+static const struct pci_device_id hisax_pci_tbl[] __used = {
 #ifdef CONFIG_HISAX_FRITZPCI
 	{PCI_VDEVICE(AVM,      PCI_DEVICE_ID_AVM_A1)			},
 #endif
-- 
2.7.4

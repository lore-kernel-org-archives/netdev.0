From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] net: ibm: ibmveth: constify dev_pm_ops structures.
Date: Thu, 29 Jun 2017 11:14:50 +0530
Message-ID: <24303710c4e099faa0ca7d9d92a71e53d6b66bcc.1498714986.git.arvind.yadav.cs@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
        tlfalcon@linux.vnet.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dev_pm_ops are not supposed to change at runtime. All functions
working with dev_pm_ops provided by <linux/device.h> work with const
dev_pm_ops. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
  15426	   1256	      0	  16682	   412a	drivers/net/ethernet/ibm/ibmveth.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  15618	   1064	      0	  16682	   412a	drivers/net/ethernet/ibm/ibmveth.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index 72ab7b6..02b26bf 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1843,7 +1843,7 @@ static int ibmveth_resume(struct device *dev)
 };
 MODULE_DEVICE_TABLE(vio, ibmveth_device_table);
 
-static struct dev_pm_ops ibmveth_pm_ops = {
+static const struct dev_pm_ops ibmveth_pm_ops = {
 	.resume = ibmveth_resume
 };
 
-- 
1.9.1

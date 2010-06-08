From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] enic: fix pci_alloc_consistent argument
Date: Tue, 8 Jun 2010 10:00:20 -0700
Message-ID: <20100608100020.7d79e932.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Scott Feldman <scofeldm@cisco.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.co>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:27575 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753642Ab0FHRCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 13:02:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix build warning on i386 (32-bit) with 32-bit dma_addr_t:

drivers/net/enic/vnic_dev.c: In function 'vnic_dev_init_prov':
drivers/net/enic/vnic_dev.c:716: warning: passing argument 3 of 'pci_alloc_consistent' from incompatible pointer type
include/asm-generic/pci-dma-compat.h:16: note: expected 'dma_addr_t *' but argument is of type 'u64 *'

Now builds without warnings on i386 and on x86_64.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc:	Scott Feldman <scofeldm@cisco.com>
Cc:	Vasanthy Kolluri <vkolluri@cisco.com>
Cc:	Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/enic/vnic_dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20100608.orig/drivers/net/enic/vnic_dev.c
+++ linux-next-20100608/drivers/net/enic/vnic_dev.c
@@ -709,7 +709,7 @@ int vnic_dev_init_prov(struct vnic_dev *
 {
 	u64 a0, a1 = len;
 	int wait = 1000;
-	u64 prov_pa;
+	dma_addr_t prov_pa;
 	void *prov_buf;
 	int ret;
 
---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

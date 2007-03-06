From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] netxen: fix warnings
Date: Tue, 6 Mar 2007 20:35:37 +0000
Message-ID: <20070306203537.GA5822@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: amitkale@netxen.com, Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:55206 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbXCFUhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 15:37:32 -0500
Received: from localhost.localdomain ([127.0.0.1]:64488 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20021453AbXCFUhb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 20:37:31 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  CC [M]  drivers/net/netxen/netxen_nic_hw.o
drivers/net/netxen/netxen_nic_hw.c: In function 'netxen_nic_hw_resources':
drivers/net/netxen/netxen_nic_hw.c:231: warning: format '%llx' expects type 'long long unsigned int', but argument 2 has type 'dma_addr_t'
drivers/net/netxen/netxen_nic_hw.c:250: warning: format '%llx' expects type 'long long unsigned int', but argument 2 has type 'dma_addr_t'

u64 is unsigned long so the cast to u64 will result in a warning on the
printf arguments for 64-bit builds.  So cast to unsigned long long instead.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index a2877f3..1be5570 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -228,7 +228,7 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 			    &adapter->ctx_desc_pdev);
 
 	printk("ctx_desc_phys_addr: 0x%llx\n",
-	       (u64) adapter->ctx_desc_phys_addr);
+	       (unsigned long long) adapter->ctx_desc_phys_addr);
 	if (addr == NULL) {
 		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");
 		err = -ENOMEM;
@@ -247,7 +247,8 @@ int netxen_nic_hw_resources(struct netxen_adapter *adapter)
 			    adapter->max_tx_desc_count,
 			    (dma_addr_t *) & hw->cmd_desc_phys_addr,
 			    &adapter->ahw.cmd_desc_pdev);
-	printk("cmd_desc_phys_addr: 0x%llx\n", (u64) hw->cmd_desc_phys_addr);
+	printk("cmd_desc_phys_addr: 0x%llx\n",
+	       (unsigned long long) hw->cmd_desc_phys_addr);
 
 	if (addr == NULL) {
 		DPRINTK(ERR, "bad return from pci_alloc_consistent\n");

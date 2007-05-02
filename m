From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 1/2] NetXen: Fix NetXen driver initialization on system-P
Date: Wed, 2 May 2007 08:15:23 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0705020813110.3154@dut46>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:22867 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S2993331AbXEBPPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 11:15:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix for driver on System-p
This patch will fix an initialization and ping issue on system-p.

Signed-off by: Milan Bag <mbag@netxen.com>
Signed-off by: Adhiraj Joshi <adhiraj@netxen.com>
Acked-by: Mithlesh Thukral <mithlesh@netxen.com>

---

  drivers/net/netxen/netxen_nic_init.c |    2 +-
  drivers/net/netxen/netxen_nic_main.c |    3 ++-
  2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index cf0e96a..a368924 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1216,7 +1216,7 @@ u32 netxen_process_rcv_ring(struct netxe
  		/* Window = 1 */
  		writel(consumer,
  		       NETXEN_CRB_NORMALIZE(adapter,
-					    recv_crb_registers[ctxid].
+					    recv_crb_registers[adapter->portnum].
  					    crb_rcv_status_consumer));
  	}

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 4e32bb6..e69c706 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -193,12 +193,13 @@ netxen_nic_probe(struct pci_dev *pdev, c
  	int pci_func_id = PCI_FUNC(pdev->devfn);

  	printk(KERN_INFO "%s \n", netxen_nic_driver_string);
-
+#ifndef CONFIG_PPC
  	if (pdev->class != 0x020000) {
  		printk(KERN_ERR"NetXen function %d, class %x will not"
  				"be enabled.\n",pci_func_id, pdev->class);
  		return -ENODEV;
  	}
+#endif
  	if ((err = pci_enable_device(pdev)))
  		return err;
  	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {

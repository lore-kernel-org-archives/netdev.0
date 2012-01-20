From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH] enic: fix compile when CONFIG_PCI_IOV is not
	enabled
Date: Fri, 20 Jan 2012 00:25:36 -0800
Message-ID: <20120120082536.18521.86316.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdunlap@xenotime.net
To: roprabhu@cisco.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-1.cisco.com ([173.36.130.12]:38204 "EHLO
	mtv-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187Ab2ATIZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 03:25:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

reverting back change that access enic->num_vfs outside
CONFIG_PCI_IOV

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 045c468..ab3f67f 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2273,7 +2273,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 #ifdef CONFIG_PCI_IOV
 	int pos = 0;
 #endif
-	int num_pps;
+	int num_pps = 1;
 
 	/* Allocate net device structure and initialize.  Private
 	 * instance data is initialized to zero.
@@ -2380,11 +2380,11 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 				goto err_out_vnic_unregister;
 			}
 			enic->priv_flags |= ENIC_SRIOV_ENABLED;
+			num_pps = enic->num_vfs;
 		}
 	}
 #endif
 
-	num_pps = enic->num_vfs ? enic->num_vfs : 1;
 	/* Allocate structure for port profiles */
 	enic->pp = kcalloc(num_pps, sizeof(*enic->pp), GFP_KERNEL);
 	if (!enic->pp) {

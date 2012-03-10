From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] e1000e, igbvf: fix default message level
Date: Sat, 10 Mar 2012 11:49:21 +0300
Message-ID: <20120310084921.GA4647@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:18758 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704Ab2CJItp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 03:49:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The intent here was to enable both NETIF_MSG_DRV and NETIF_MSG_PROBE
messages, but in the original code only the NETIF_MSG_DRV bit was set.

NETIF_MSG_DRV and NETIF_MSG_PROBE are bits 0 and 1, they are not
supposed to be used to do a shift.  I think the confusion is because
the msg_enable can also be controlled through ethtool which passes a bit
number that is used to do a bit shift.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 217c143..e50c2ec 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2649,7 +2649,7 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 	adapter->flags = ei->flags;
 	adapter->hw.back = adapter;
 	adapter->hw.mac.type = ei->mac;
-	adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
+	adapter->msg_enable = NETIF_MSG_DRV | NETIF_MSG_PROBE;
 
 	/* PCI config space info */
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 7152eb1..0e2de0b 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6172,7 +6172,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	adapter->hw.adapter = adapter;
 	adapter->hw.mac.type = ei->mac;
 	adapter->max_hw_frame_size = ei->max_hw_frame_size;
-	adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
+	adapter->msg_enable = NETIF_MSG_DRV | NETIF_MSG_PROBE;
 
 	mmio_start = pci_resource_start(pdev, 0);
 	mmio_len = pci_resource_len(pdev, 0);

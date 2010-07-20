From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/5] ixgbe: use GFP_ATOMIC when allocating FCoE
	DDP context from the dma pool
Date: Mon, 19 Jul 2010 17:00:24 -0700
Message-ID: <20100720000021.14112.63604.stgit@localhost.localdomain>
References: <20100719235831.14112.14175.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:39885
	"EHLO qmta03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761012Ab0GTAAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 20:00:44 -0400
In-Reply-To: <20100719235831.14112.14175.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

The FCoE protocol stack may hold a lock when this gets called.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 1737d2b..072327c 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -190,7 +190,7 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 	}
 
 	/* alloc the udl from our ddp pool */
-	ddp->udl = pci_pool_alloc(fcoe->pool, GFP_KERNEL, &ddp->udp);
+	ddp->udl = pci_pool_alloc(fcoe->pool, GFP_ATOMIC, &ddp->udp);
 	if (!ddp->udl) {
 		e_err(drv, "failed allocated ddp context\n");
 		goto out_noddp_unmap;


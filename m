From: Roland Dreier <rdreier@cisco.com>
Subject: RDMA/nes: Fix mis-merge
Date: Thu, 26 Mar 2009 16:25:49 -0700
Message-ID: <adahc1fuarm.fsf_-_@cisco.com>
References: <20090326.020714.36421849.davem@davemloft.net>
	<20090326.152515.43533230.davem@davemloft.net>
	<alpine.LFD.2.00.0903261555290.3032@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:20855 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760227AbZCZXZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 19:25:51 -0400
In-Reply-To: <alpine.LFD.2.00.0903261555290.3032@localhost.localdomain> (Linus
	Torvalds's message of "Thu, 26 Mar 2009 15:56:24 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When net-next and infiniband were merged upstream, each branch deleted
one of a pair of adjacent lines from nes_nic.c, but when Linus fixed the
conflict up, he brought back both of the lines.  Fix up to the intended
final tree state.
---
 > Well, I merged infiniband, and that caused more conflicts. I fixed them 
 > up, but people need to double-check my fixes.

Looks like you mismerged one file -- each side deleted one line right
next to each other, but your merge left both lines in.  I think the
patch below is needed.  (The cxgb3 fix looks correct)

 drivers/infiniband/hw/nes/nes_nic.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 8d3e4c6..ecb1f6f 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1602,8 +1602,6 @@ struct net_device *nes_netdev_init(struct nes_device *nesdev,
 	netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);
 	nes_debug(NES_DBG_INIT, "Enabling VLAN Insert/Delete.\n");
 	netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	netdev->vlan_rx_register = nes_netdev_vlan_rx_register;
-	netdev->features |= NETIF_F_LLTX;
 
 	/* Fill in the port structure */
 	nesvnic->netdev = netdev;

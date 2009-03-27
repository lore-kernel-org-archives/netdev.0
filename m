From: Roland Dreier <rdreier@cisco.com>
Subject: [PATCH] RDMA/nes: Fix mis-merge
Date: Fri, 27 Mar 2009 12:16:25 -0700
Message-ID: <ada4oxeu67q.fsf_-_@cisco.com>
References: <20090326.020714.36421849.davem@davemloft.net>
	<20090326.152515.43533230.davem@davemloft.net>
	<alpine.LFD.2.00.0903261555290.3032@localhost.localdomain>
	<adahc1fuarm.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:30867 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360AbZC0TQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 15:16:27 -0400
In-Reply-To: <adahc1fuarm.fsf_-_@cisco.com> (Roland Dreier's message of "Thu,
	26 Mar 2009 16:25:49 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When net-next and infiniband were merged upstream, each branch deleted
one of a pair of adjacent lines from nes_nic.c, but when Linus fixed the
conflict up, he brought back both of the lines.  Fix up to the intended
final tree state.

Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
Resending because this seems to have gotten dropped (probably because I
forgot my s-o-b the first time around); in the meantime I have tested
the iw_nes driver with this patch applied and it works (at least enough
to run some light traffic)

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

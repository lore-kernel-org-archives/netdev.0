From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH -next] myri10ge: clear NETIF_F_LRO bit directly
Date: Tue, 29 Jun 2010 16:37:31 +0200
Message-ID: <20100629163731.1d174b07@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5289 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756151Ab0F2Ohm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 10:37:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not use ethtool_op_set_flags() to clear one bit in ->features.
Inform user about disabling LRO.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/myri10ge/myri10ge.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index e0b47cc..2259168 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1725,17 +1725,15 @@ static u32 myri10ge_get_rx_csum(struct net_device *netdev)
 static int myri10ge_set_rx_csum(struct net_device *netdev, u32 csum_enabled)
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
-	int err = 0;
 
 	if (csum_enabled)
 		mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
 	else {
-		u32 flags = ethtool_op_get_flags(netdev);
-		err = ethtool_op_set_flags(netdev, (flags & ~ETH_FLAG_LRO));
 		mgp->csum_flag = 0;
-
+		netdev->features &= ~NETIF_F_LRO;
+		netdev_info(netdev, "RX checksumming set off, disabling LRO\n");
 	}
-	return err;
+	return 0;
 }
 
 static int myri10ge_set_tso(struct net_device *netdev, u32 tso_enabled)
-- 
1.5.5.6


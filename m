From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH -next] vmxnet3: fail when try to setup unsupported features
Date: Mon, 28 Jun 2010 11:29:42 +0200
Message-ID: <20100628112942.0c919746@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Amerigo Wang <amwang@redhat.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13720 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020Ab0F1J3s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 05:29:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return EOPNOTSUPP in ethtool_ops->set_flags.

Fix coding style while at it.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/vmxnet3/vmxnet3_ethtool.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 3935c44..8a71a21 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -276,16 +276,21 @@ vmxnet3_get_strings(struct net_device *netdev, u32 stringset, u8 *buf)
 }
 
 static u32
-vmxnet3_get_flags(struct net_device *netdev) {
+vmxnet3_get_flags(struct net_device *netdev)
+{
 	return netdev->features;
 }
 
 static int
-vmxnet3_set_flags(struct net_device *netdev, u32 data) {
+vmxnet3_set_flags(struct net_device *netdev, u32 data)
+{
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	u8 lro_requested = (data & ETH_FLAG_LRO) == 0 ? 0 : 1;
 	u8 lro_present = (netdev->features & NETIF_F_LRO) == 0 ? 0 : 1;
 
+	if (data & ~ETH_FLAG_LRO)
+		return -EOPNOTSUPP;
+
 	if (lro_requested ^ lro_present) {
 		/* toggle the LRO feature*/
 		netdev->features ^= NETIF_F_LRO;
-- 
1.5.5.6


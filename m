From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH net-next] openvswitch: Set internal device max mtu to ETH_MAX_MTU.
Date: Tue, 14 Feb 2017 21:16:28 -0800
Message-ID: <1487135788-37601-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, jarod@redhat.com, pshelar@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:44283 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750781AbdBOFQo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 00:16:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 91572088e3fd ("net: use core MTU range checking in core net
infra") changed the openvswitch internal device to use the core net
infra for controlling the MTU range, but failed to actually set the
max_mtu as described in the commit message, which now defaults to
ETH_DATA_LEN.

This patch fixes this by setting max_mtu to ETH_MAX_MTU after
ether_setup() call.

Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
 net/openvswitch/vport-internal_dev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 09141a1..89193a6 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -149,6 +149,8 @@ static void do_setup(struct net_device *netdev)
 {
 	ether_setup(netdev);
 
+	netdev->max_mtu = ETH_MAX_MTU;
+
 	netdev->netdev_ops = &internal_dev_netdev_ops;
 
 	netdev->priv_flags &= ~IFF_TX_SKB_SHARING;
-- 
2.1.4

From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH v2 08/14] bridge: Add support for TX vlan offload.
Date: Wed, 20 Oct 2010 16:56:08 -0700
Message-ID: <1287618974-4714-9-git-send-email-jesse@nicira.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:55512 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053Ab0JTX4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 19:56:33 -0400
Received: by mail-qw0-f46.google.com with SMTP id 26so2908363qwa.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 16:56:33 -0700 (PDT)
In-Reply-To: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If some of the underlying devices support it, enable vlan offload on
transmit for bridge devices.  This allows senders to take advantage of the
hardware support, similar to other forms of acceleration.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/bridge/br_device.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index cf09fe5..17cb0b6 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -212,6 +212,11 @@ static int br_set_tx_csum(struct net_device *dev, u32 data)
 	return 0;
 }
 
+static int br_set_flags(struct net_device *netdev, u32 data)
+{
+	return ethtool_op_set_flags(netdev, data, ETH_FLAG_TXVLAN);
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void br_poll_controller(struct net_device *br_dev)
 {
@@ -304,6 +309,7 @@ static const struct ethtool_ops br_ethtool_ops = {
 	.get_ufo	= ethtool_op_get_ufo,
 	.set_ufo	= ethtool_op_set_ufo,
 	.get_flags	= ethtool_op_get_flags,
+	.set_flags	= br_set_flags,
 };
 
 static const struct net_device_ops br_netdev_ops = {
@@ -343,5 +349,5 @@ void br_dev_setup(struct net_device *dev)
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | NETIF_F_LLTX |
-			NETIF_F_NETNS_LOCAL | NETIF_F_GSO;
+			NETIF_F_NETNS_LOCAL | NETIF_F_GSO | NETIF_F_HW_VLAN_TX;
 }
-- 
1.7.1


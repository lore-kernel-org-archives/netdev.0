From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH][net-next] gianfar: fix default tx vlan offload feature flag
Date: Fri, 24 Aug 2012 10:46:25 +0300
Message-ID: <1345794385-21908-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Sebastian Poehn <sebastian.poehn@belden.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:11553 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751817Ab2HXHqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 03:46:39 -0400
Received: from mail183-tx2 (localhost [127.0.0.1])	by
 mail183-tx2-R.bigfish.com (Postfix) with ESMTP id 4FDBF38015C	for
 <netdev@vger.kernel.org>; Fri, 24 Aug 2012 07:46:36 +0000 (UTC)
Received: from TX2EHSMHS011.bigfish.com (unknown [10.9.14.248])	by
 mail183-tx2.bigfish.com (Postfix) with ESMTP id C560BE0153	for
 <netdev@vger.kernel.org>; Fri, 24 Aug 2012 07:46:34 +0000 (UTC)
Received: from zro04-ws574.ea.freescale.net ([10.213.130.145])	by
 tx30smr01.am.freescale.net (8.14.3/8.14.0) with ESMTP id q7O7kWE6015642	for
 <netdev@vger.kernel.org>; Fri, 24 Aug 2012 00:46:33 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit -
"b852b72 gianfar: fix bug caused by
87c288c6e9aa31720b72e2bc2d665e24e1653c3e"
disables by default (on mac init) the hw vlan tag insertion.
The "features" flags were not updated to reflect this, and
"ethtool -K" shows tx-vlan-offload to be "on" by default.

Cc: Sebastian Poehn <sebastian.poehn@belden.com>
Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4605f72..d3233f59 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1041,7 +1041,7 @@ static int gfar_probe(struct platform_device *ofdev)
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_VLAN) {
 		dev->hw_features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		dev->features |= NETIF_F_HW_VLAN_RX;
 	}
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_EXTENDED_HASH) {
-- 
1.7.6.5

From: leitao@linux.vnet.ibm.com
Subject: [PATCH] ehea: add the correct LRO status at dev->features
Date: Mon,  6 Dec 2010 14:39:42 -0200
Message-ID: <1291653582-14177-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:52998 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837Ab0LFQj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 11:39:57 -0500
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp01.br.ibm.com (8.14.4/8.13.1) with ESMTP id oB6H18rq002990
	for <netdev@vger.kernel.org>; Mon, 6 Dec 2010 15:01:08 -0200
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB6GkwVc864380
	for <netdev@vger.kernel.org>; Mon, 6 Dec 2010 14:46:58 -0200
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB6Gdqc8003272
	for <netdev@vger.kernel.org>; Mon, 6 Dec 2010 14:39:53 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently ehea is not setting NETIF_F_LRO, and it is not providing
a callback for get_flags on ethtool. This patch fixes it.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea_ethtool.c |    1 +
 drivers/net/ehea/ehea_main.c    |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
index 75b099c..b0892b0 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -273,6 +273,7 @@ const struct ethtool_ops ehea_ethtool_ops = {
 	.get_ethtool_stats = ehea_get_ethtool_stats,
 	.get_rx_csum = ehea_get_rx_csum,
 	.set_settings = ehea_set_settings,
+	.get_flags = ethtool_op_get_flags,
 	.nway_reset = ehea_nway_reset,		/* Restart autonegotiation */
 };
 
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index a84c389..da75846 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3266,6 +3266,9 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 		      | NETIF_F_LLTX;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
+	if (use_lro)
+		dev->features |= NETIF_F_LRO;
+
 	INIT_WORK(&port->reset_task, ehea_reset_port);
 
 	ret = register_netdev(dev);
-- 
1.7.3.2


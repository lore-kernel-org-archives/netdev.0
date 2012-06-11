From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] lpc_eth: add missing ndo_change_mtu()
Date: Mon, 11 Jun 2012 11:24:00 +0200
Message-ID: <1339406640.6001.1896.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, stigge@antcom.de,
	kevin.wells@nxp.com, aletes.xgr@gmail.com, srinivas.bakki@nxp.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63838 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068Ab2FKJYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 05:24:04 -0400
Received: by eaak11 with SMTP id k11so1727995eaa.19
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 02:24:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

lpc_eth does a copy of transmitted skbs to DMA area, without checking
skb lengths, so can trigger buffer overflows :

memcpy(pldat->tx_buff_v + txidx * ENET_MAXF_SIZE, skb->data, len);

One way to get bigger skbs is to allow MTU changes above the 1500 limit.

Calling eth_change_mtu() in ndo_change_mtu() makes sure this cannot
happen.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Roland Stigge <stigge@antcom.de>
Cc: Kevin Wells <kevin.wells@nxp.com>
---
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 8d2666f..10febdc 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1320,6 +1320,7 @@ static const struct net_device_ops lpc_netdev_ops = {
 	.ndo_set_rx_mode	= lpc_eth_set_multicast_list,
 	.ndo_do_ioctl		= lpc_eth_ioctl,
 	.ndo_set_mac_address	= lpc_set_mac_address,
+	.ndo_change_mtu		= eth_change_mtu,
 };
 
 static int lpc_eth_drv_probe(struct platform_device *pdev)

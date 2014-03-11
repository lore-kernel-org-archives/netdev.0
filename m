From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next] bcm63xx_enet: Stop pretending to support netpoll
Date: Tue, 11 Mar 2014 14:33:35 -0700
Message-ID: <87ppls774g.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:46898 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754595AbaCKVdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 17:33:40 -0400
In-Reply-To: <20140311.160931.1395978386605601765.davem@davemloft.net> (David
	Miller's message of "Tue, 11 Mar 2014 16:09:31 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


bcm_enet_netpoll does not exist, and causing
bcm63xx_net to fail to build when NET_POLL_CONTROLLER
is defined.

Remove the bogus .ndo_poll_controller = bcm_enet_netpoll

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index b9a5fb6400d3..a7d11f5565d6 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1722,9 +1722,6 @@ static const struct net_device_ops bcm_enet_ops = {
 	.ndo_set_rx_mode	= bcm_enet_set_multicast_list,
 	.ndo_do_ioctl		= bcm_enet_ioctl,
 	.ndo_change_mtu		= bcm_enet_change_mtu,
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller = bcm_enet_netpoll,
-#endif
 };
 
 /*
-- 
1.7.5.4

From: Fugang Duan <B38611@freescale.com>
Subject: [PATCH] net: fec: fix build warning of used uninitialized variable
Date: Thu, 22 Aug 2013 18:00:37 +0800
Message-ID: <1377165637-8116-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<bhutchings@solarflare.com>, <R49496@freescale.com>,
	<stephen@networkplumber.org>
To: <b20596@freescale.com>, <b45643@freescale.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe005.messaging.microsoft.com ([216.32.180.188]:15587
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752123Ab3HVKEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 06:04:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/ethernet/freescale/fec_main.c:838
warning: 'vlan_tag' may be used uninitialized in this function
note: 'vlan_tag' was declared here

Compiler with the warning option: -Wuninitialized, the warning
will be reported.

Signed-off-by: Fugang Duan  <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 77ea0db..4ea1555 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -835,7 +835,7 @@ fec_enet_rx(struct net_device *ndev, int budget)
 	int	pkt_received = 0;
 	struct	bufdesc_ex *ebdp = NULL;
 	bool	vlan_packet_rcvd = false;
-	u16	vlan_tag;
+	u16	vlan_tag = 0;
 
 #ifdef CONFIG_M532x
 	flush_cache_all();
-- 
1.7.1

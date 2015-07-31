From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 2/4] veth: Don't segment multiple tagged packets on veth device
Date: Fri, 31 Jul 2015 15:03:25 +0900
Message-ID: <1438322608-4688-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1438322608-4688-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:34454 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062AbbGaGDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 02:03:52 -0400
In-Reply-To: <1438322608-4688-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veth devices don't need to segment multiple tagged packets.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 drivers/net/veth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index c8186ff..343592c 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -290,6 +290,7 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_poll_controller	= veth_poll_controller,
 #endif
 	.ndo_get_iflink		= veth_get_iflink,
+	.ndo_features_check	= passthru_features_check,
 };
 
 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
-- 
1.8.1.2

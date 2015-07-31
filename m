From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 4/4] tuntap: Don't segment multiple tagged packets on tap device
Date: Fri, 31 Jul 2015 15:03:27 +0900
Message-ID: <1438322608-4688-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1438322608-4688-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:34453 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbbGaGDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 02:03:52 -0400
In-Reply-To: <1438322608-4688-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tap devices don't need to segment multiple tagged packets.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 drivers/net/tun.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 06a0394..976aa97 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -961,6 +961,7 @@ static const struct net_device_ops tap_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= tun_poll_controller,
 #endif
+	.ndo_features_check	= passthru_features_check,
 };
 
 static void tun_flow_init(struct tun_struct *tun)
-- 
1.8.1.2

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 1/4] macvlan: Don't segment multiple tagged packets on macvlan device
Date: Fri, 31 Jul 2015 15:03:24 +0900
Message-ID: <1438322608-4688-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1438322608-4688-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:42642 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbbGaGD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 02:03:57 -0400
In-Reply-To: <1438322608-4688-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macvlan/macvtap devices don't need to segment multiple tagged packets
since the lower devices can segment them.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 drivers/net/macvlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9f59f17..47da435 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1047,6 +1047,7 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_netpoll_cleanup	= macvlan_dev_netpoll_cleanup,
 #endif
 	.ndo_get_iflink		= macvlan_dev_get_iflink,
+	.ndo_features_check	= passthru_features_check,
 };
 
 void macvlan_common_setup(struct net_device *dev)
-- 
1.8.1.2

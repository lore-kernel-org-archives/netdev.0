From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] mlx4: set csum_complete_sw bit when fixing complete csum
Date: Mon, 27 Jun 2016 11:22:04 -0700
Message-ID: <1467051724-8314-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35216 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbcF0SWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 14:22:12 -0400
Received: by mail-pa0-f66.google.com with SMTP id hf6so15983655pac.2
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 11:22:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The stack doesn't trust the complete csum by hardware
even when it is correct. In the case we fix csum by ourself
probably it is safe to just mark it as completed by software.

This should shut up a kernel warning from netdev_rx_csum_fault()
with mlx4 driver for ICMP packets.

Fixes: f8c6455bb04b ('net/mlx4_en: Extend checksum offloading by CHECKSUM COMPLETE')
Cc: Shani Michaeli <shanim@mellanox.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Yishai Hadas <yishaih@mellanox.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index c1b3a9c..b44c434 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -732,6 +732,7 @@ static int check_csum(struct mlx4_cqe *cqe, struct sk_buff *skb, void *va,
 		if (get_fixed_ipv6_csum(hw_checksum, skb, hdr))
 			return -1;
 #endif
+	skb->csum_complete_sw = 1;
 	return 0;
 }
 
-- 
2.1.0

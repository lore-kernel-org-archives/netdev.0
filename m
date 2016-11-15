From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/5] net/mlx4_en: use napi_complete_done() return value
Date: Tue, 15 Nov 2016 10:15:14 -0800
Message-ID: <1479233715-9905-5-git-send-email-edumazet@google.com>
References: <1479233715-9905-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Adam Belay <abelay@google.com>, Zach Brown <zach.brown@ni.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34374 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932110AbcKOSQI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:16:08 -0500
Received: by mail-pf0-f178.google.com with SMTP id c4so25488996pfb.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 10:16:08 -0800 (PST)
In-Reply-To: <1479233715-9905-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not rearm interrupts if we are busy polling.

mlx4 uses separate CQ for TX and RX, so number of TX interrupts
does not change, unfortunately.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Adam Belay <abelay@google.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
Cc: Ariel Elior <ariel.elior@cavium.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 2cc91002064f..22f08f9ef464 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1137,8 +1137,8 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 		done = 0;
 	}
 	/* Done for now */
-	napi_complete_done(napi, done);
-	mlx4_en_arm_cq(priv, cq);
+	if (napi_complete_done(napi, done))
+		mlx4_en_arm_cq(priv, cq);
 	return done;
 }
 
-- 
2.8.0.rc3.226.g39d4020

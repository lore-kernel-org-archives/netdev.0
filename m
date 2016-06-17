From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: switchx2: Don't count internal TX header bytes to stats
Date: Fri, 17 Jun 2016 15:09:06 +0200
Message-ID: <1466168946-14658-3-git-send-email-jiri@resnulli.us>
References: <1466168946-14658-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34204 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932553AbcFQNJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 09:09:13 -0400
Received: by mail-wm0-f68.google.com with SMTP id 187so16624090wmz.1
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 06:09:12 -0700 (PDT)
In-Reply-To: <1466168946-14658-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Stop the SW TX counter from counting the TX header bytes
since they are not being sent out.

Fixes: e577516b9db3 ("mlxsw: Fix use-after-free bug in mlxsw_sx_port_xmit")
Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 3842eab..25f658b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -316,7 +316,10 @@ static netdev_tx_t mlxsw_sx_port_xmit(struct sk_buff *skb,
 		}
 	}
 	mlxsw_sx_txhdr_construct(skb, &tx_info);
-	len = skb->len;
+	/* TX header is consumed by HW on the way so we shouldn't count its
+	 * bytes as being sent.
+	 */
+	len = skb->len - MLXSW_TXHDR_LEN;
 	/* Due to a race we might fail here because of a full queue. In that
 	 * unlikely case we simply drop the packet.
 	 */
-- 
2.5.5

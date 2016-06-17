From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: spectrum: Don't count internal TX header bytes to stats
Date: Fri, 17 Jun 2016 15:09:05 +0200
Message-ID: <1466168946-14658-2-git-send-email-jiri@resnulli.us>
References: <1466168946-14658-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33032 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932742AbcFQNJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 09:09:12 -0400
Received: by mail-wm0-f66.google.com with SMTP id r201so4406720wme.0
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 06:09:11 -0700 (PDT)
In-Reply-To: <1466168946-14658-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Stop the SW TX counter from counting the TX header bytes
since they are not being sent out.

Fixes: 56ade8fe3fe1 ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6f9e3dd..660429e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -408,7 +408,11 @@ static netdev_tx_t mlxsw_sp_port_xmit(struct sk_buff *skb,
 	}
 
 	mlxsw_sp_txhdr_construct(skb, &tx_info);
-	len = skb->len;
+	/* TX header is consumed by HW on the way so we shouldn't count its
+	 * bytes as being sent.
+	 */
+	len = skb->len - MLXSW_TXHDR_LEN;
+
 	/* Due to a race we might fail here because of a full queue. In that
 	 * unlikely case we simply drop the packet.
 	 */
-- 
2.5.5

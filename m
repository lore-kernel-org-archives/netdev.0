From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 05/13] Bluetooth: Only check SAR bits if frame is an I-frame
Date: Thu,  8 Jul 2010 16:59:54 -0300
Message-ID: <913d694fd876be6fb6fc54177fe793b23583e239.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36219 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758543Ab0GHUAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:35 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <padovan@profusion.mobi>

The SAR bits doesn't make sense for an S-frame. It doesn't use SAR.

Checking SAR for a S-frames can lead to L2CAP errors, it could close
the channel with an invalid packet length, since we was removing the 2
of the of any frame that match SAR start bits, without check if it is
an I-frame.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index bca8c41..fa842cc 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -4110,7 +4110,7 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 		skb_pull(skb, 2);
 		len = skb->len;
 
-		if (__is_sar_start(control))
+		if (__is_sar_start(control) && __is_iframe(control))
 			len -= 2;
 
 		if (pi->fcs == L2CAP_FCS_CRC16)
-- 
1.7.1.1


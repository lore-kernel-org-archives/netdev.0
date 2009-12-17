From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 2/5] Bluetooth: Fix unset of RemoteBusy flag for L2CAP
Date: Thu, 17 Dec 2009 12:22:44 -0800
Message-ID: <186de9a33803c7ee20d9af75c9049b50e68a3a08.1261080894.git.marcel@holtmann.org>
References: <cover.1261080894.git.marcel@holtmann.org>
 <971beb83aeb2a309175682cf5683d64fd4591841.1261080894.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33952 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936876AbZLQUXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 15:23:19 -0500
In-Reply-To: <971beb83aeb2a309175682cf5683d64fd4591841.1261080894.git.marcel@holtmann.org>
In-Reply-To: <cover.1261080894.git.marcel@holtmann.org>
References: <cover.1261080894.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

RemoteBusy flag need to be unset before l2cap_ertm_send(), otherwise
l2cap_ertm_send() will return without sending packets because it checks
that flag before start sending.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 5129b88..7db9a1f 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3435,8 +3435,8 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 			    (pi->unacked_frames > 0))
 				__mod_retrans_timer();
 
-			l2cap_ertm_send(sk);
 			pi->conn_state &= ~L2CAP_CONN_REMOTE_BUSY;
+			l2cap_ertm_send(sk);
 		}
 		break;
 
-- 
1.6.5.2


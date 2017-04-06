From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 06/19] batman-adv: Use __func__ to add function names to messages
Date: Thu,  6 Apr 2017 16:07:28 +0200
Message-ID: <20170406140741.30745-7-sw@simonwunderlich.de>
References: <20170406140741.30745-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:32934 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935010AbdDFOHs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:48 -0400
In-Reply-To: <20170406140741.30745-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The name of the function might change in which these messages are printed.
It is therefore better to let the compiler handle the insertion of the
correct function name.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/tp_meter.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/tp_meter.c b/net/batman-adv/tp_meter.c
index c94ebdecdc3d..556f9a865ddf 100644
--- a/net/batman-adv/tp_meter.c
+++ b/net/batman-adv/tp_meter.c
@@ -873,8 +873,8 @@ static int batadv_tp_send(void *arg)
 		/* something went wrong during the preparation/transmission */
 		if (unlikely(err && err != BATADV_TP_REASON_CANT_SEND)) {
 			batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
-				   "Meter: batadv_tp_send() cannot send packets (%d)\n",
-				   err);
+				   "Meter: %s() cannot send packets (%d)\n",
+				   __func__, err);
 			/* ensure nobody else tries to stop the thread now */
 			if (atomic_dec_and_test(&tp_vars->sending))
 				tp_vars->reason = err;
@@ -979,7 +979,8 @@ void batadv_tp_start(struct batadv_priv *bat_priv, const u8 *dst,
 	if (!tp_vars) {
 		spin_unlock_bh(&bat_priv->tp_list_lock);
 		batadv_dbg(BATADV_DBG_TP_METER, bat_priv,
-			   "Meter: batadv_tp_start cannot allocate list elements\n");
+			   "Meter: %s cannot allocate list elements\n",
+			   __func__);
 		batadv_tp_batctl_error_notify(BATADV_TP_REASON_MEMORY_ERROR,
 					      dst, bat_priv, session_cookie);
 		return;
-- 
2.11.0

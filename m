From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 2/2] batman-adv: Detect missing primaryif during tp_send as error
Date: Sat, 19 Nov 2016 12:06:14 +0100
Message-ID: <20161119110614.23325-3-sw@simonwunderlich.de>
References: <20161119110614.23325-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:49416 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752505AbcKSLGT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 06:06:19 -0500
In-Reply-To: <20161119110614.23325-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The throughput meter detects different situations as problems for the
current test. It stops the test after these and reports it to userspace.
This also has to be done when the primary interface disappeared during the
test.

Fixes: 33a3bb4a3345 ("batman-adv: throughput meter implementation")
Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/tp_meter.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/batman-adv/tp_meter.c b/net/batman-adv/tp_meter.c
index 2333777..8af1611 100644
--- a/net/batman-adv/tp_meter.c
+++ b/net/batman-adv/tp_meter.c
@@ -837,6 +837,7 @@ static int batadv_tp_send(void *arg)
 	primary_if = batadv_primary_if_get_selected(bat_priv);
 	if (unlikely(!primary_if)) {
 		err = BATADV_TP_REASON_DST_UNREACHABLE;
+		tp_vars->reason = err;
 		goto out;
 	}
 
-- 
2.10.2

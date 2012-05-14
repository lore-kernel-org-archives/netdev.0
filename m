From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 4/8] batman-adv: refactor window_protected to avoid unnecessary return statement
Date: Mon, 14 May 2012 09:17:34 +0200
Message-ID: <1336979858-13928-5-git-send-email-ordex@autistici.org>
References: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:51771 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601Ab2ENHRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 03:17:11 -0400
In-Reply-To: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Reported-by: David Laight <David.Laight@aculab.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/routing.c |   15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index b1824bb..840e2c6 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -234,17 +234,14 @@ int window_protected(struct bat_priv *bat_priv, int32_t seq_num_diff,
 {
 	if ((seq_num_diff <= -TQ_LOCAL_WINDOW_SIZE) ||
 	    (seq_num_diff >= EXPECTED_SEQNO_RANGE)) {
-		if (has_timed_out(*last_reset, RESET_PROTECTION_MS)) {
-
-			*last_reset = jiffies;
-			bat_dbg(DBG_BATMAN, bat_priv,
-				"old packet received, start protection\n");
-
-			return 0;
-		} else {
+		if (!has_timed_out(*last_reset, RESET_PROTECTION_MS))
 			return 1;
-		}
+
+		*last_reset = jiffies;
+		bat_dbg(DBG_BATMAN, bat_priv,
+			"old packet received, start protection\n");
 	}
+
 	return 0;
 }
 
-- 
1.7.9.4

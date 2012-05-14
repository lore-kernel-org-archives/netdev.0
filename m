From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 8/8] batman-adv: unset the TT_CLIENT_PENDING flag if the new local entry already exists
Date: Mon, 14 May 2012 09:17:38 +0200
Message-ID: <1336979858-13928-9-git-send-email-ordex@autistici.org>
References: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:51725 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754704Ab2ENHRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 03:17:13 -0400
In-Reply-To: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When trying to add a new tt_local_entry, if such entry already exists, we have
to ensure that the TT_CLIENT_PENDING flag is not set, otherwise the entry will
be deleted soon.

Reported-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index b3fb597..a66c2dc 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -206,6 +206,8 @@ void tt_local_add(struct net_device *soft_iface, const uint8_t *addr,
 
 	if (tt_local_entry) {
 		tt_local_entry->last_seen = jiffies;
+		/* possibly unset the TT_CLIENT_PENDING flag */
+		tt_local_entry->common.flags &= ~TT_CLIENT_PENDING;
 		goto out;
 	}
 
-- 
1.7.9.4

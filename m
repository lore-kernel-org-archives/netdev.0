From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 01/13] batman-adv: convert the tt_crc to network order
Date: Wed, 18 Apr 2012 11:59:58 +0200
Message-ID: <1334743210-12338-2-git-send-email-ordex@autistici.org>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:24539 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858Ab2DRJ7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 05:59:23 -0400
In-Reply-To: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before sending out a TT_Request packet we must convert the tt_crc field value
to network order (since it is 16bits long).

Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index e16a369..a38d315 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1339,7 +1339,7 @@ static int send_tt_request(struct bat_priv *bat_priv,
 	memcpy(tt_request->dst, dst_orig_node->orig, ETH_ALEN);
 	tt_request->header.ttl = TTL;
 	tt_request->ttvn = ttvn;
-	tt_request->tt_data = tt_crc;
+	tt_request->tt_data = htons(tt_crc);
 	tt_request->flags = TT_REQUEST;
 
 	if (full_table)
-- 
1.7.9.4

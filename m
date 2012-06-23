From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 1/2 net] batman-adv: only drop packets of known wifi clients
Date: Sat, 23 Jun 2012 17:30:58 +0200
Message-ID: <1340465459-2949-2-git-send-email-ordex@autistici.org>
References: <1340465459-2949-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:53260 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764Ab2FWPbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 11:31:00 -0400
In-Reply-To: <1340465459-2949-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

bug introduced with 59b699cdee039d75915c354da06937102d1f9a84

If the source or destination mac address of an ethernet packet
could not be found in the translation table the packet was
dropped if AP isolation was turned on. This behavior would
make it impossible to send broadcast packets over the mesh as
the broadcast address will never enter the translation table.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/translation-table.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index a66c2dc..660c40f 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2031,10 +2031,10 @@ bool is_ap_isolated(struct bat_priv *bat_priv, uint8_t *src, uint8_t *dst)
 {
 	struct tt_local_entry *tt_local_entry = NULL;
 	struct tt_global_entry *tt_global_entry = NULL;
-	bool ret = true;
+	bool ret = false;
 
 	if (!atomic_read(&bat_priv->ap_isolation))
-		return false;
+		goto out;
 
 	tt_local_entry = tt_local_hash_find(bat_priv, dst);
 	if (!tt_local_entry)
@@ -2044,10 +2044,10 @@ bool is_ap_isolated(struct bat_priv *bat_priv, uint8_t *src, uint8_t *dst)
 	if (!tt_global_entry)
 		goto out;
 
-	if (_is_ap_isolated(tt_local_entry, tt_global_entry))
+	if (!_is_ap_isolated(tt_local_entry, tt_global_entry))
 		goto out;
 
-	ret = false;
+	ret = true;
 
 out:
 	if (tt_global_entry)
-- 
1.7.9.4

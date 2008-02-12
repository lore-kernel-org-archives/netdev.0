From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NETLABEL]: Fix lookup logic of netlbl_domhsh_search_def.
Date: Tue, 12 Feb 2008 19:27:16 +0300
Message-ID: <47B1C8E4.6010908@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <paul.moore@hp.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:48708 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763518AbYBLQ1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 11:27:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if the call to netlbl_domhsh_search succeeds the
return result will still be NULL.

Fix that, by returning the found entry (if any).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/netlabel/netlabel_domainhash.c b/net/netlabel/netlabel_domainhash.c
index 9a8ea01..fd46231 100644
--- a/net/netlabel/netlabel_domainhash.c
+++ b/net/netlabel/netlabel_domainhash.c
@@ -150,11 +150,11 @@ static struct netlbl_dom_map *netlbl_domhsh_search_def(const char *domain)
 	entry = netlbl_domhsh_search(domain);
 	if (entry == NULL) {
 		entry = rcu_dereference(netlbl_domhsh_def);
-		if (entry != NULL && entry->valid)
-			return entry;
+		if (entry != NULL && !entry->valid)
+			entry = NULL;
 	}
 
-	return NULL;
+	return entry;
 }
 
 /*

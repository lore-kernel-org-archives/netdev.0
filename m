From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] netlabel: Fix a potential NULL pointer dereference
Date: Mon, 01 Dec 2008 22:27:55 -0500
Message-ID: <20081202032755.17851.61631.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:31479 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbYLBD2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 22:28:01 -0500
Received: from g1t0038.austin.hp.com (g1t0038.austin.hp.com [16.236.32.44])
	by g5t0008.atlanta.hp.com (Postfix) with ESMTP id EC38A247AA
	for <netdev@vger.kernel.org>; Tue,  2 Dec 2008 03:28:00 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a potential NULL pointer dereference seen when trying to remove a static
label configuration with an invalid address/mask combination.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/netlabel/netlabel_unlabeled.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index e8a5c32..90c8506 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -574,9 +574,10 @@ static int netlbl_unlhsh_remove_addr4(struct net *net,
 	list_entry = netlbl_af4list_remove(addr->s_addr, mask->s_addr,
 					   &iface->addr4_list);
 	spin_unlock(&netlbl_unlhsh_lock);
-	if (list_entry == NULL)
+	if (list_entry != NULL)
+		entry = netlbl_unlhsh_addr4_entry(list_entry);
+	else
 		ret_val = -ENOENT;
-	entry = netlbl_unlhsh_addr4_entry(list_entry);
 
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_UNLBL_STCDEL,
 					      audit_info);
@@ -634,9 +635,10 @@ static int netlbl_unlhsh_remove_addr6(struct net *net,
 	spin_lock(&netlbl_unlhsh_lock);
 	list_entry = netlbl_af6list_remove(addr, mask, &iface->addr6_list);
 	spin_unlock(&netlbl_unlhsh_lock);
-	if (list_entry == NULL)
+	if (list_entry != NULL)
+		entry = netlbl_unlhsh_addr6_entry(list_entry);
+	else
 		ret_val = -ENOENT;
-	entry = netlbl_unlhsh_addr6_entry(list_entry);
 
 	audit_buf = netlbl_audit_start_common(AUDIT_MAC_UNLBL_STCDEL,
 					      audit_info);


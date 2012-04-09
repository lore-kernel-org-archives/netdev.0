From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] net/key/af_key.c: add missing kfree_skb
Date: Mon,  9 Apr 2012 10:41:10 +0200
Message-ID: <1333960870-19735-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:60742 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546Ab2DIIlQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2012 04:41:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

At the point of this error-handling code, alloc_skb has succeded, so free
the resulting skb by jumping to the err label.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 net/key/af_key.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 11dbb22..7e5d927 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3480,7 +3480,7 @@ static int pfkey_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 
 	/* Addresses to be used by KM for negotiation, if ext is available */
 	if (k != NULL && (set_sadb_kmaddress(skb, k) < 0))
-		return -EINVAL;
+		goto err;
 
 	/* selector src */
 	set_sadb_address(skb, sasize_sel, SADB_EXT_ADDRESS_SRC, sel);

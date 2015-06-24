From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH 1/1] ppp: remove NULL check before kfree
Date: Wed, 24 Jun 2015 15:09:42 +0530
Message-ID: <1435138782-48477-1-git-send-email-maninder1.s@samsung.com>
Cc: pankaj.m@samsung.com, Maninder Singh <maninder1.s@samsung.com>
To: paulus@samba.org, linux-ppp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:39244 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbbFXJlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 05:41:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need of explicit NULL check before kfree,
removing the same and little coding style changes.

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Reviewed-by: Vaneet narang <v.narang@samsung.com>
---
 drivers/net/ppp/ppp_mppe.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 05005c6..06f60b1 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -238,12 +238,11 @@ static void *mppe_alloc(unsigned char *options, int optlen)
 	return (void *)state;
 
 	out_free:
-	    if (state->sha1_digest)
 		kfree(state->sha1_digest);
 	    if (state->sha1)
-		crypto_free_hash(state->sha1);
+			crypto_free_hash(state->sha1);
 	    if (state->arc4)
-		crypto_free_blkcipher(state->arc4);
+			crypto_free_blkcipher(state->arc4);
 	    kfree(state);
 	out:
 	return NULL;
@@ -256,12 +255,11 @@ static void mppe_free(void *arg)
 {
 	struct ppp_mppe_state *state = (struct ppp_mppe_state *) arg;
 	if (state) {
-	    if (state->sha1_digest)
 		kfree(state->sha1_digest);
 	    if (state->sha1)
-		crypto_free_hash(state->sha1);
+			crypto_free_hash(state->sha1);
 	    if (state->arc4)
-		crypto_free_blkcipher(state->arc4);
+			crypto_free_blkcipher(state->arc4);
 	    kfree(state);
 	}
 }
-- 
1.7.9.5

From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 4/7] ip/xfrm: Do not print a zero-length algorithm key
Date: Mon, 25 Mar 2013 10:23:16 -0400
Message-ID: <1364221399-1024-4-git-send-email-david.ward@ll.mit.edu>
References: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:42072 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758242Ab3CYOX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 10:23:29 -0400
Received: from LLE2K7-HUB01.mitll.ad.local (LLE2K7-HUB01.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id r2PEN2cv023593 for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 10:23:28 -0400
In-Reply-To: <1364221399-1024-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 ip/ipxfrm.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 2576938..3113573 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -536,12 +536,14 @@ static void __xfrm_algo_print(struct xfrm_algo *algo, int type, int len,
 		goto fin;
 	}
 
-	fprintf(fp, "0x");
-	for (i = 0; i < keylen; i ++)
-		fprintf(fp, "%.2x", (unsigned char)algo->alg_key[i]);
+	if (keylen > 0) {
+		fprintf(fp, "0x");
+		for (i = 0; i < keylen; i ++)
+			fprintf(fp, "%.2x", (unsigned char)algo->alg_key[i]);
 
-	if (show_stats > 0)
-		fprintf(fp, " (%d bits)", algo->alg_key_len);
+		if (show_stats > 0)
+			fprintf(fp, " (%d bits)", algo->alg_key_len);
+	}
 
  fin:
 	if (newline)
-- 
1.7.1

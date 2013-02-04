From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next] mcast: do not check 'rv' twice in a row
Date: Mon,  4 Feb 2013 00:34:10 -0700
Message-ID: <1359963250-7729-1-git-send-email-sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:45117 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825Ab3BDHet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 02:34:49 -0500
Received: by mail-pa0-f42.google.com with SMTP id kq12so327039pab.1
        for <netdev@vger.kernel.org>; Sun, 03 Feb 2013 23:34:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the loop, don't check 'rv' twice in a row. Without the loop, 'rv'
doesn't even need to be checked.

Make the comment more grammar-friendly.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 net/ipv6/mcast.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 8460a1f..e5de4855 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -427,11 +427,9 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 	rv = 1;	/* > 0 for insert logic below if sl_count is 0 */
 	for (i=0; i<psl->sl_count; i++) {
 		rv = !ipv6_addr_equal(&psl->sl_addr[i], source);
-		if (rv == 0)
-			break;
+		if (rv == 0) /* There is an error in the address. */
+			goto done;
 	}
-	if (rv == 0)		/* address already there is an error */
-		goto done;
 	for (j=psl->sl_count-1; j>=i; j--)
 		psl->sl_addr[j+1] = psl->sl_addr[j];
 	psl->sl_addr[i] = *source;

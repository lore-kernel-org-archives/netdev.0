From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH] net: drop write-only stack variable
Date: Tue,  2 Feb 2016 18:17:54 +0100
Message-ID: <1454433474-8888-1-git-send-email-dh.herrmann@gmail.com>
Cc: "David S . Miller" <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35201 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932649AbcBBRSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 12:18:13 -0500
Received: by mail-wm0-f54.google.com with SMTP id r129so128269757wmr.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 09:18:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove a write-only stack variable from unix_attach_fds(). This is a
left-over from the security fix in:

    commit 712f4aad406bb1ed67f3f98d04c044191f0ff593
    Author: willy tarreau <w@1wt.eu>
    Date:   Sun Jan 10 07:54:56 2016 +0100

        unix: properly account for FDs passed over unix sockets

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
---
 net/unix/af_unix.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index c5bf5ef..9f88193 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1534,7 +1534,6 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
 {
 	int i;
 	unsigned char max_level = 0;
-	int unix_sock_count = 0;
 
 	if (too_many_unix_fds(current))
 		return -ETOOMANYREFS;
@@ -1542,11 +1541,9 @@ static int unix_attach_fds(struct scm_cookie *scm, struct sk_buff *skb)
 	for (i = scm->fp->count - 1; i >= 0; i--) {
 		struct sock *sk = unix_get_socket(scm->fp->fp[i]);
 
-		if (sk) {
-			unix_sock_count++;
+		if (sk)
 			max_level = max(max_level,
 					unix_sk(sk)->recursion_level);
-		}
 	}
 	if (unlikely(max_level > MAX_RECURSION_LEVEL))
 		return -ETOOMANYREFS;
-- 
2.7.0

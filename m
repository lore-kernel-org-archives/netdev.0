From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH net-next] af_unix: optimize unix_writable by inlining
Date: Mon,  2 Nov 2015 12:01:59 -0500
Message-ID: <1446483719-30310-1-git-send-email-aconole@bytheb.org>
Cc: Aaron Conole <aconole@bytheb.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:36683 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932116AbbKBRCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 12:02:10 -0500
Received: by qgad10 with SMTP id d10so120968901qga.3
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 09:02:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

unix_writable() originally was inlined, but was changed as part of
commit 1586a5877db9 ("af_unix: do not report POLLOUT on
listeners"). Re-enable the inline flag.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/unix/af_unix.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index aaa0b58..f0c7f0c 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -326,7 +326,7 @@ found:
 	return s;
 }
 
-static int unix_writable(const struct sock *sk)
+static inline int unix_writable(const struct sock *sk)
 {
 	return sk->sk_state != TCP_LISTEN &&
 	       (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
-- 
2.6.1.133.gf5b6079

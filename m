From: Ed Schouten <ed@nuxi.nl>
Subject: [PATCH 3/3] Return ENOTCONN when trying to recv() on an unconnected UNIX socket.
Date: Thu,  3 Mar 2016 12:23:02 +0100
Message-ID: <1457004183-24933-3-git-send-email-ed@nuxi.nl>
References: <1457004183-24933-1-git-send-email-ed@nuxi.nl>
Cc: Ed Schouten <ed@nuxi.nl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:33534 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756852AbcCCLXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 06:23:13 -0500
Received: by mail-wm0-f50.google.com with SMTP id l68so30129868wml.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 03:23:12 -0800 (PST)
In-Reply-To: <1457004183-24933-1-git-send-email-ed@nuxi.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both POSIX and our manual pages state that if send() or recv() is called
on an unconnected socket, ENOTCONN should be returned. It looks like our
implementation of send() already does this, but recv() does not.

Reference:
http://pubs.opengroup.org/onlinepubs/009695399/functions/send.html

Signed-off-by: Ed Schouten <ed@nuxi.nl>
---
 net/unix/af_unix.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index d810815..824dd63 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2283,7 +2283,7 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state)
 	unsigned int last_len;
 
 	if (unlikely(sk->sk_state != TCP_ESTABLISHED)) {
-		err = -EINVAL;
+		err = -ENOTCONN;
 		goto out;
 	}
 
-- 
2.5.0

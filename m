From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 2/2] X.25 remove bkl in poll
Date: Wed, 22 Sep 2010 11:24:45 +1000
Message-ID: <1285118685.28503.46.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:41780 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755752Ab0IVBYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 21:24:51 -0400
Received: by qyk36 with SMTP id 36so4573206qyk.19
        for <netdev@vger.kernel.org>; Tue, 21 Sep 2010 18:24:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The x25_datagram_poll didn't add anything, removed it.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 4ebde0d..b371a47 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -923,18 +923,6 @@ out:
 	return rc;
 }
 
-static unsigned int x25_datagram_poll(struct file *file, struct socket *sock,
-			   poll_table *wait)
-{
-	int rc;
-
-	lock_kernel();
-	rc = datagram_poll(file, sock, wait);
-	unlock_kernel();
-
-	return rc;
-}
-
 int x25_rx_call_request(struct sk_buff *skb, struct x25_neigh *nb,
 			unsigned int lci)
 {
@@ -1742,7 +1730,7 @@ static const struct proto_ops x25_proto_ops = {
 	.socketpair =	sock_no_socketpair,
 	.accept =	x25_accept,
 	.getname =	x25_getname,
-	.poll =		x25_datagram_poll,
+	.poll =		datagram_poll,
 	.ioctl =	x25_ioctl,
 #ifdef CONFIG_COMPAT
 	.compat_ioctl = compat_x25_ioctl,
-- 
1.7.0.4




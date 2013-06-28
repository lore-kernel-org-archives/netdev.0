From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: Check the argument for listen(2)
Date: Sat, 29 Jun 2013 00:14:36 +0800
Message-ID: <1372436076-61436-1-git-send-email-xiaosuo@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36805 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755427Ab3F1QPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 12:15:48 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz11so2597154pad.30
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 09:15:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we use u16 to save the value of the argument for listen(2),
we'd better check if the value is larger than SINT_MAX other
than cut it down silently on error.
---
 net/ipv4/af_inet.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index b4d0be2..35aaf00 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -198,6 +198,9 @@ int inet_listen(struct socket *sock, int backlog)
 	unsigned char old_state;
 	int err;
 
+	if (backlog >= (1 << 16))
+		return EINVAL;
+
 	lock_sock(sk);
 
 	err = -EINVAL;
-- 
1.7.9.5

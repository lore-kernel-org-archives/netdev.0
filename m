From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH] net: ipv6: fix wrong ping_v6_sendmsg return value
Date: Thu,  4 Jul 2013 00:12:40 +0900
Message-ID: <1372864360-9450-1-git-send-email-lorenzo@google.com>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, lorenzo@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:58137 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161Ab3GCPND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 11:13:03 -0400
Received: by mail-yh0-f74.google.com with SMTP id z20so24139yhz.1
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 08:13:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ping_v6_sendmsg currently returns 0 on success. It should return
the number of bytes written instead.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv6/ping.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 2b52046..29d9d47 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -189,7 +189,10 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 						 len);
 	}
 
-	return err;
+	if (err)
+		return err;
+
+	return len;
 }
 
 #ifdef CONFIG_PROC_FS
-- 
1.8.3

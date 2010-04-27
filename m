From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] rps: inet_rps_save_rxhash() argument is not
 const
Date: Tue, 27 Apr 2010 14:42:51 +0200
Message-ID: <1272372171.2295.68.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:58304 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630Ab0D0Mm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 08:42:56 -0400
Received: by bwz19 with SMTP id 19so23943bwz.21
        for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 05:42:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

const qualifier on sock argument is misleading, since we can modify rxhash.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index b487bc1..c1d4295 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -248,7 +248,7 @@ static inline void inet_rps_reset_flow(const struct sock *sk)
 #endif
 }
 
-static inline void inet_rps_save_rxhash(const struct sock *sk, u32 rxhash)
+static inline void inet_rps_save_rxhash(struct sock *sk, u32 rxhash)
 {
 #ifdef CONFIG_RPS
 	if (unlikely(inet_sk(sk)->rxhash != rxhash)) {



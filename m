From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 3/7] tcp: __tcp_hdrlen() helper
Date: Tue,  9 Feb 2016 18:39:09 -0500
Message-ID: <1455061153-7855-4-git-send-email-kraigatgoog@gmail.com>
References: <1455061153-7855-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:34265 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756209AbcBIXjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 18:39:23 -0500
Received: by mail-qg0-f41.google.com with SMTP id b67so2429221qgb.1
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 15:39:23 -0800 (PST)
In-Reply-To: <1455061153-7855-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

tcp_hdrlen is wasteful if you already have a pointer to struct tcphdr.
This splits the size calculation into a helper function that can be
used if a struct tcphdr is already available.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/linux/tcp.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index b386361ba3e8..c216707d63bf 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -29,9 +29,14 @@ static inline struct tcphdr *tcp_hdr(const struct sk_buff *skb)
 	return (struct tcphdr *)skb_transport_header(skb);
 }
 
+static inline unsigned int __tcp_hdrlen(const struct tcphdr *th)
+{
+	return th->doff * 4;
+}
+
 static inline unsigned int tcp_hdrlen(const struct sk_buff *skb)
 {
-	return tcp_hdr(skb)->doff * 4;
+	return __tcp_hdrlen(tcp_hdr(skb));
 }
 
 static inline struct tcphdr *inner_tcp_hdr(const struct sk_buff *skb)
-- 
2.7.0.rc3.207.g0ac5344

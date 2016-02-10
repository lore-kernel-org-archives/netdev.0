From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next v4 3/7] tcp: __tcp_hdrlen() helper
Date: Wed, 10 Feb 2016 11:50:37 -0500
Message-ID: <1455123041-22638-4-git-send-email-kraigatgoog@gmail.com>
References: <1455123041-22638-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:35945 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067AbcBJQuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 11:50:51 -0500
Received: by mail-qg0-f52.google.com with SMTP id y9so18026607qgd.3
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 08:50:51 -0800 (PST)
In-Reply-To: <1455123041-22638-1-git-send-email-kraigatgoog@gmail.com>
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
index d909feeeaea2..bcbf51da4e1e 100644
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

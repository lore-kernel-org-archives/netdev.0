From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] Right prototype of __raw_v4_lookup()
Date: Sun, 28 May 2006 01:09:32 +0400
Message-ID: <20060527210932.GB7267@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:6325 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964970AbWE0VJG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 17:09:06 -0400
Received: by nf-out-0910.google.com with SMTP id k26so10707nfc
        for <netdev@vger.kernel.org>; Sat, 27 May 2006 14:09:05 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All users pass 32-bit values as addresses and internally they're compared with
32-bit entities. So, change "laddr" and "raddr" types to __be32.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/raw.h |    2 +-
 net/ipv4/raw.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- a/include/net/raw.h
+++ 1/include/net/raw.h
@@ -36,7 +36,7 @@ extern rwlock_t raw_v4_lock;
 
 
 extern struct sock *__raw_v4_lookup(struct sock *sk, unsigned short num,
-				    unsigned long raddr, unsigned long laddr,
+				    __be32 raddr, __be32 laddr,
 				    int dif);
 
 extern int raw_v4_input(struct sk_buff *skb, struct iphdr *iph, int hash);
--- linux-vanilla/net/ipv4/raw.c
+++ linux-1/net/ipv4/raw.c
@@ -103,7 +103,7 @@ static void raw_v4_unhash(struct sock *s
 }
 
 struct sock *__raw_v4_lookup(struct sock *sk, unsigned short num,
-			     unsigned long raddr, unsigned long laddr,
+			     __be32 raddr, __be32 laddr,
 			     int dif)
 {
 	struct hlist_node *node;


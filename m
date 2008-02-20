From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 6/8] [NET]: uninline skb_trim, de-bloats
Date: Wed, 20 Feb 2008 15:47:16 +0200
Message-ID: <1203515238-22848-7-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-6-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44100 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754775AbYBTNrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 08:47:21 -0500
In-Reply-To: <1203515238-22848-6-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-10976  209 funcs, 123 +, 11099 -, diff: -10976 --- skb_trim

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/skbuff.h |   16 +---------------
 net/core/skbuff.c      |   16 ++++++++++++++++
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c11f248..75d8a66 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1156,21 +1156,7 @@ static inline void __skb_trim(struct sk_buff *sk=
b, unsigned int len)
 	skb_set_tail_pointer(skb, len);
 }
=20
-/**
- *	skb_trim - remove end from a buffer
- *	@skb: buffer to alter
- *	@len: new length
- *
- *	Cut the length of a buffer down by removing data from the tail. If
- *	the buffer is already under the length specified it is not modified=
=2E
- *	The skb must be linear.
- */
-static inline void skb_trim(struct sk_buff *skb, unsigned int len)
-{
-	if (skb->len > len)
-		__skb_trim(skb, len);
-}
-
+extern void skb_trim(struct sk_buff *skb, unsigned int len);
=20
 static inline int __pskb_trim(struct sk_buff *skb, unsigned int len)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 05d43fd..b57cadb 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -931,6 +931,22 @@ unsigned char *skb_pull(struct sk_buff *skb, unsig=
ned int len)
 }
 EXPORT_SYMBOL(skb_pull);
=20
+/**
+ *	skb_trim - remove end from a buffer
+ *	@skb: buffer to alter
+ *	@len: new length
+ *
+ *	Cut the length of a buffer down by removing data from the tail. If
+ *	the buffer is already under the length specified it is not modified=
=2E
+ *	The skb must be linear.
+ */
+void skb_trim(struct sk_buff *skb, unsigned int len)
+{
+	if (skb->len > len)
+		__skb_trim(skb, len);
+}
+EXPORT_SYMBOL(skb_trim);
+
 /* Trims skb to length len. It can change skb pointers.
  */
=20
--=20
1.5.2.2


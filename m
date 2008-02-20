From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 4/8] [NET]: uninline skb_push, de-bloats a lot
Date: Wed, 20 Feb 2008 15:47:14 +0200
Message-ID: <1203515238-22848-5-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi>
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
	with ESMTP id S1753882AbYBTNrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 08:47:20 -0500
In-Reply-To: <1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-21593  356 funcs, 2418 +, 24011 -, diff: -21593 --- skb_push

Again, current_text_addr() needs to addressed.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/skbuff.h |   18 +-----------------
 net/core/skbuff.c      |   19 +++++++++++++++++++
 2 files changed, 20 insertions(+), 17 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index df3cce2..c11f248 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -905,23 +905,7 @@ static inline unsigned char *__skb_push(struct sk_=
buff *skb, unsigned int len)
 	return skb->data;
 }
=20
-/**
- *	skb_push - add data to the start of a buffer
- *	@skb: buffer to use
- *	@len: amount of data to add
- *
- *	This function extends the used data area of the buffer at the buffe=
r
- *	start. If this would exceed the total buffer headroom the kernel wi=
ll
- *	panic. A pointer to the first byte of the extra data is returned.
- */
-static inline unsigned char *skb_push(struct sk_buff *skb, unsigned in=
t len)
-{
-	skb->data -=3D len;
-	skb->len  +=3D len;
-	if (unlikely(skb->data<skb->head))
-		skb_under_panic(skb, len, current_text_addr());
-	return skb->data;
-}
+extern unsigned char *skb_push(struct sk_buff *skb, unsigned int len);
=20
 static inline unsigned char *__skb_pull(struct sk_buff *skb, unsigned =
int len)
 {
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 081bffb..05d43fd 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -897,6 +897,25 @@ unsigned char *skb_put(struct sk_buff *skb, unsign=
ed int len)
 EXPORT_SYMBOL(skb_put);
=20
 /**
+ *	skb_push - add data to the start of a buffer
+ *	@skb: buffer to use
+ *	@len: amount of data to add
+ *
+ *	This function extends the used data area of the buffer at the buffe=
r
+ *	start. If this would exceed the total buffer headroom the kernel wi=
ll
+ *	panic. A pointer to the first byte of the extra data is returned.
+ */
+unsigned char *skb_push(struct sk_buff *skb, unsigned int len)
+{
+	skb->data -=3D len;
+	skb->len  +=3D len;
+	if (unlikely(skb->data<skb->head))
+		skb_under_panic(skb, len, current_text_addr());
+	return skb->data;
+}
+EXPORT_SYMBOL(skb_push);
+
+/**
  *	skb_pull - remove data from the start of a buffer
  *	@skb: buffer to use
  *	@len: amount of data to remove
--=20
1.5.2.2


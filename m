From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 2/8] [NET]: uninline skb_pull, de-bloats a lot
Date: Wed, 20 Feb 2008 15:47:12 +0200
Message-ID: <1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47679 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635AbYBTNrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 08:47:21 -0500
In-Reply-To: <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-28162  354 funcs, 3005 +, 31167 -, diff: -28162 --- skb_pull

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/skbuff.h |   15 +--------------
 net/core/skbuff.c      |   16 ++++++++++++++++
 2 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5925435..a9f8f15 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -930,20 +930,7 @@ static inline unsigned char *__skb_pull(struct sk_=
buff *skb, unsigned int len)
 	return skb->data +=3D len;
 }
=20
-/**
- *	skb_pull - remove data from the start of a buffer
- *	@skb: buffer to use
- *	@len: amount of data to remove
- *
- *	This function removes data from the start of a buffer, returning
- *	the memory to the headroom. A pointer to the next data in the buffe=
r
- *	is returned. Once the data has been pulled future pushes will overw=
rite
- *	the old data.
- */
-static inline unsigned char *skb_pull(struct sk_buff *skb, unsigned in=
t len)
-{
-	return unlikely(len > skb->len) ? NULL : __skb_pull(skb, len);
-}
+extern unsigned char *skb_pull(struct sk_buff *skb, unsigned int len);
=20
 extern unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta)=
;
=20
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 661d439..14f462b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -878,6 +878,22 @@ unsigned char *skb_put(struct sk_buff *skb, unsign=
ed int len)
 }
 EXPORT_SYMBOL(skb_put);
=20
+/**
+ *	skb_pull - remove data from the start of a buffer
+ *	@skb: buffer to use
+ *	@len: amount of data to remove
+ *
+ *	This function removes data from the start of a buffer, returning
+ *	the memory to the headroom. A pointer to the next data in the buffe=
r
+ *	is returned. Once the data has been pulled future pushes will overw=
rite
+ *	the old data.
+ */
+unsigned char *skb_pull(struct sk_buff *skb, unsigned int len)
+{
+	return unlikely(len > skb->len) ? NULL : __skb_pull(skb, len);
+}
+EXPORT_SYMBOL(skb_pull);
+
 /* Trims skb to length len. It can change skb pointers.
  */
=20
--=20
1.5.2.2


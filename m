From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/7] [NET]: uninline skb_pull, de-bloats a lot
Date: Thu, 27 Mar 2008 14:38:01 +0200
Message-ID: <1206621486-5408-3-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55645 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759291AbYC0MiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 08:38:09 -0400
In-Reply-To: <1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allyesconfig (v2.6.24-mm1):

-28162  354 funcs, 3005 +, 31167 -, diff: -28162 --- skb_pull

Without number of debug related CONFIGs (v2.6.25-rc2-mm1):

-9697  338 funcs, 221 +, 9918 -, diff: -9697 --- skb_pull
skb_pull                      |  +44

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/skbuff.h |   16 +---------------
 net/core/skbuff.c      |   16 ++++++++++++++++
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f085955..6d6cde7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -927,6 +927,7 @@ static inline unsigned char *skb_push(struct sk_buf=
f *skb, unsigned int len)
 	return skb->data;
 }
=20
+extern unsigned char *skb_pull(struct sk_buff *skb, unsigned int len);
 static inline unsigned char *__skb_pull(struct sk_buff *skb, unsigned =
int len)
 {
 	skb->len -=3D len;
@@ -934,21 +935,6 @@ static inline unsigned char *__skb_pull(struct sk_=
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
-
 extern unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta)=
;
=20
 static inline unsigned char *__pskb_pull(struct sk_buff *skb, unsigned=
 int len)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3402eca..cf489b6 100644
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


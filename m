From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/7] [NET]: uninline dev_alloc_skb, de-bloats a lot
Date: Thu, 27 Mar 2008 14:38:02 +0200
Message-ID: <1206621486-5408-4-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1206621486-5408-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1206621486-5408-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1206621486-5408-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42424 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757088AbYC0MiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 08:38:09 -0400
In-Reply-To: <1206621486-5408-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allyesconfig (v2.6.24-mm1):

-23668  392 funcs, 104 +, 23772 -, diff: -23668 --- dev_alloc_skb

Without many debug CONFIGs (v2.6.25-rc2-mm1):

-12178  382 funcs, 157 +, 12335 -, diff: -12178 --- dev_alloc_skb
dev_alloc_skb                 |  +37

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/skbuff.h |   17 +----------------
 net/core/skbuff.c      |   18 ++++++++++++++++++
 2 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6d6cde7..01a11b0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1272,22 +1272,7 @@ static inline struct sk_buff *__dev_alloc_skb(un=
signed int length,
 	return skb;
 }
=20
-/**
- *	dev_alloc_skb - allocate an skbuff for receiving
- *	@length: length to allocate
- *
- *	Allocate a new &sk_buff and assign it a usage count of one. The
- *	buffer has unspecified headroom built in. Users should allocate
- *	the headroom they think they need without accounting for the
- *	built in space. The built in space is used for optimisations.
- *
- *	%NULL is returned if there is no free memory. Although this functio=
n
- *	allocates memory it can be called from an interrupt.
- */
-static inline struct sk_buff *dev_alloc_skb(unsigned int length)
-{
-	return __dev_alloc_skb(length, GFP_ATOMIC);
-}
+extern struct sk_buff *dev_alloc_skb(unsigned int length);
=20
 extern struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 		unsigned int length, gfp_t gfp_mask);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cf489b6..0daf5c0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -263,6 +263,24 @@ struct sk_buff *__netdev_alloc_skb(struct net_devi=
ce *dev,
 	return skb;
 }
=20
+/**
+ *	dev_alloc_skb - allocate an skbuff for receiving
+ *	@length: length to allocate
+ *
+ *	Allocate a new &sk_buff and assign it a usage count of one. The
+ *	buffer has unspecified headroom built in. Users should allocate
+ *	the headroom they think they need without accounting for the
+ *	built in space. The built in space is used for optimisations.
+ *
+ *	%NULL is returned if there is no free memory. Although this functio=
n
+ *	allocates memory it can be called from an interrupt.
+ */
+struct sk_buff *dev_alloc_skb(unsigned int length)
+{
+	return __dev_alloc_skb(length, GFP_ATOMIC);
+}
+EXPORT_SYMBOL(dev_alloc_skb);
+
 static void skb_drop_list(struct sk_buff **listp)
 {
 	struct sk_buff *list =3D *listp;
--=20
1.5.2.2


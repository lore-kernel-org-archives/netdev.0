From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 01/46] net: introduce __netdev_alloc_skb_aligned()
Date: Mon, 11 Jul 2011 02:52:46 +0200 (CEST)
Message-ID: <ae7b531c89a01a21e4374907b69f4d997c9d5d1b.1310339688.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43646 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594Ab1GKAwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:49 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce __netdev_alloc_skb_aligned() to return skb with skb->data
aligned at specified 2^n multiple.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/skbuff.h |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 32ada53..c873897 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1561,6 +1561,33 @@ extern struct sk_buff *__netdev_alloc_skb(struct=
 net_device *dev,
 		unsigned int length, gfp_t gfp_mask);
=20
 /**
+ *	__netdev_alloc_skb_aligned - allocate an skbuff for rx on a specifi=
c device
+ *	@dev: network device to receive on
+ *	@length: length to allocate
+ *	@align: required skb->data alignment
+ *	@gfp_mask: get_free_pages mask, passed to alloc_skb
+ *
+ *	Allocate a new &sk_buff and assign it a usage count of one. The
+ *	buffer has unspecified headroom built in. Users should allocate
+ *	the headroom they think they need without accounting for the
+ *	built in space. The built in space is used for optimisations.
+ *
+ *	%NULL is returned if there is no free memory.
+ */
+static inline struct sk_buff *__netdev_alloc_skb_aligned(struct net_de=
vice *dev,
+		unsigned int length, unsigned int align, gfp_t gfp_mask)
+{
+	struct sk_buff *skb;
+
+	skb =3D __alloc_skb(length + NET_SKB_PAD + align, gfp_mask, 0, NUMA_N=
O_NODE);
+	if (likely(skb)) {
+		skb_reserve(skb, PTR_ALIGN(skb->data + NET_SKB_PAD, align) - skb->da=
ta);
+		skb->dev =3D dev;
+	}
+	return skb;
+}
+
+/**
  *	netdev_alloc_skb - allocate an skbuff for rx on a specific device
  *	@dev: network device to receive on
  *	@length: length to allocate
--=20
1.7.5.4


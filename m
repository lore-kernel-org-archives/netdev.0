From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 05/13] xfrm: Add callbacks for IPsec GSO offloading
Date: Thu, 4 Feb 2016 07:36:58 +0100
Message-ID: <1454567826-13018-6-git-send-email-steffen.klassert@secunet.com>
References: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36667 "EHLO
	h-62.96.220.36.host.de.colt.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751703AbcBDHFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 02:05:48 -0500
In-Reply-To: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares struct xfrm_type for IPsec GSO offloading by
adding a encap() callback for encapsulation and a output_tail()
callback to do the crypto operations after the return from the
GSO layer. We need the output_tail() callback to handle async
crypto operations.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index aed7153..a33ceb7 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -375,6 +375,8 @@ struct xfrm_type {
 	void			(*destructor)(struct xfrm_state *);
 	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
 	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
+	int			(*output_tail)(struct xfrm_state *x, struct sk_buff *skb);
+	void			(*encap)(struct xfrm_state *x, struct sk_buff *skb);
 	int			(*reject)(struct xfrm_state *, struct sk_buff *,
 					  const struct flowi *);
 	int			(*hdr_offset)(struct xfrm_state *, struct sk_buff *, u8 **);
-- 
1.9.1

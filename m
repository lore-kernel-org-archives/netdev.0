From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH v2] xfrm: Fix inter family IPsec tunnel handling again
Date: Wed, 9 Jul 2008 16:24:18 +0200
Message-ID: <20080709142418.GT9549@secunet.com>
References: <20080705071950.GA26532@secunet.com> <20080705115654.GA18290@gondor.apana.org.au> <20080708095335.GP9549@secunet.com> <20080708104022.GA26280@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:52402 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751879AbYGIOYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2008 10:24:30 -0400
Content-Disposition: inline
In-Reply-To: <20080708104022.GA26280@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 08, 2008 at 06:40:22PM +0800, Herbert Xu wrote:
> 
> I discussed this with Miyazawa-san earlier in the year.  In order
> to maintain backwards compatibility, the use of AF_UNSPEC needs to
> be combined with an SA flag.  So let's create a new flag that can
> be set by the applications which needs the AF_UNSPEC behaviour.
> 

Just to get you right, do you mean something like the patch below?
With this and a patched iproute2 I've got the inter family tunnels running.

Steffen

---
 include/linux/xfrm.h |    1 +
 net/xfrm/xfrm_user.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 2ca6bae..fb0c215 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -339,6 +339,7 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_NOPMTUDISC	4
 #define XFRM_STATE_WILDRECV	8
 #define XFRM_STATE_ICMP		16
+#define XFRM_STATE_AF_UNSPEC	32
 };
 
 struct xfrm_usersa_id {
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index b976d9e..04c4150 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -277,9 +277,8 @@ static void copy_from_user_state(struct xfrm_state *x, struct xfrm_usersa_info *
 	memcpy(&x->props.saddr, &p->saddr, sizeof(x->props.saddr));
 	x->props.flags = p->flags;
 
-	if (!x->sel.family)
+	if (!x->sel.family && !(p->flags & XFRM_STATE_AF_UNSPEC))
 		x->sel.family = p->family;
-
 }
 
 /*
-- 
1.5.3


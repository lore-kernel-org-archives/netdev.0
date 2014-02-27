From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/5] xfrm: Fix NULL pointer dereference on sub policy usage
Date: Thu, 27 Feb 2014 07:16:36 +0100
Message-ID: <1393481799-20492-3-git-send-email-steffen.klassert@secunet.com>
References: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57427 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbaB0GQt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 01:16:49 -0500
In-Reply-To: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_state_sort() takes the unsorted states from the src array
and stores them into the dst array. We try to get the namespace
from the dst array which is empty at this time, so take the
namespace from the src array instead.

Fixes: 283bc9f35bbbc ("xfrm: Namespacify xfrm state/policy locks")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a26b7aa..97d117b 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1451,7 +1451,7 @@ xfrm_state_sort(struct xfrm_state **dst, struct xfrm_state **src, int n,
 {
 	int err = 0;
 	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
-	struct net *net = xs_net(*dst);
+	struct net *net = xs_net(*src);
 
 	if (!afinfo)
 		return -EAFNOSUPPORT;
-- 
1.7.9.5

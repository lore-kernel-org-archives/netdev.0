From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/4] xfrm: Restrict extended sequence numbers to esp
Date: Tue, 29 Mar 2011 07:48:09 +0200
Message-ID: <20110329054809.GL1290@secunet.com>
References: <20110329054552.GI1290@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52882 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752347Ab1C2FsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Mar 2011 01:48:12 -0400
Content-Disposition: inline
In-Reply-To: <20110329054552.GI1290@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IPsec extended sequence numbers are fully implemented just for
esp. So restrict the usage to esp until other protocols have
support too.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index ccc4c0c..3d15d3e 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -127,6 +127,9 @@ static inline int verify_replay(struct xfrm_usersa_info *p,
 	if (!rt)
 		return 0;
 
+	if (p->id.proto != IPPROTO_ESP)
+		return -EINVAL;
+
 	if (p->replay_window != 0)
 		return -EINVAL;
 
-- 
1.7.0.4


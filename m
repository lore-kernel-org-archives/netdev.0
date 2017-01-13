From: Colin King <colin.king@canonical.com>
Subject: [PATCH] xfrm: state: fix potential null pointer dereference on afinfo
Date: Fri, 13 Jan 2017 14:07:03 +0000
Message-ID: <20170113140703.20961-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55024 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750898AbdAMOIK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 09:08:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

afinfo is being null checked before a call afinfo->init_tempsel
so afinfo may be potentially null. ifinfo may still be null in
the case were it is not updated when family == tmpl->encap_family,
hence we may hit a null pointer dereference in the call to
afinfo->init_temprop.

Fix this by adding a null ptr check before calling init_temprop.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/xfrm/xfrm_state.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a62097e..5083418 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -656,7 +656,8 @@ xfrm_init_tempstate(struct xfrm_state *x, const struct flowi *fl,
 		if (!afinfo)
 			return;
 	}
-	afinfo->init_temprop(x, tmpl, daddr, saddr);
+	if (afinfo)
+		afinfo->init_temprop(x, tmpl, daddr, saddr);
 }
 
 static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark,
-- 
2.10.2

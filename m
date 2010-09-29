From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] [XFRM]: Don't dereference error pointer dst1
Date: Thu, 30 Sep 2010 00:37:23 +0200
Message-ID: <4CA3BFA3.1060204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't dereference dst1 when it's an error pointer.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 net/xfrm/xfrm_policy.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

I just noticed this by code analysis. It wasn't tested in any way.

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index cbab6e1..b186c3d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1414,13 +1414,14 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 
 	for (; i < nx; i++) {
 		struct xfrm_dst *xdst = xfrm_alloc_dst(net, family);
-		struct dst_entry *dst1 = &xdst->u.dst;
+		struct dst_entry *dst1;
 
 		err = PTR_ERR(xdst);
 		if (IS_ERR(xdst)) {
 			dst_release(dst);
 			goto put_states;
 		}
+		dst1 = &xdst->u.dst;
 
 		if (!dst_prev)
 			dst0 = dst1;

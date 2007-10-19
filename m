From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [PATCH] netdev: Reset ipv4 flags during bundle creation on interfamily ipsec
Date: Fri, 19 Oct 2007 14:40:16 +0300
Message-ID: <200710191440.17232.joakim.koskela@hiit.fi>
References: <200710191437.39449.joakim.koskela@hiit.fi>
Reply-To: joakim.koskela@hiit.fi
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Patrick McHardy" <kaber@trash.net>,
	"Herbert Xu" <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:53436 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757134AbXJSLoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 07:44:22 -0400
In-Reply-To: <200710191437.39449.joakim.koskela@hiit.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch resets the ipv4-related flags in the new flow as their
content will otherwise depend on the bits of the ipv6 addresses the
struct was previously used for. For example, fl4_tos might have
RTO_ONLINK set, which usually prevents the right route from being
found.

This bit was chopped off the larger patch dealing with the problems
related to creating the bundles for inter-family tranformations.

Signed-off-by: Joakim Koskela <jookos@gmail.com>
--

diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 82e27b8..386a762 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -184,6 +184,8 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 			case AF_INET:
 				fl_tunnel.fl4_dst = xfrm[i]->id.daddr.a4;
 				fl_tunnel.fl4_src = xfrm[i]->props.saddr.a4;
+				fl_tunnel.fl4_tos = 0;
+				fl_tunnel.fl4_scope = 0;
 				break;
 			case AF_INET6:
 				ipv6_addr_copy(&fl_tunnel.fl6_dst, __xfrm6_bundle_addr_remote(xfrm[i], &fl->fl6_dst));

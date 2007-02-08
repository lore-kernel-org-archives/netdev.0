From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][3/6] fix to refer encap_family when comparing with
 the xfrm_state
Date: Thu, 8 Feb 2007 17:04:05 +0900
Message-ID: <20070208170405.d8775199.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:41276 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1161544AbXBHIL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 03:11:29 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the address family to refer encap_family when comparing
with a kernel generated xfrm_state

Signed-off-by Kazunori MIYAZAWA <miyazawa@linux-ipv6.org>

---
 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b7e537f..6e7214f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1550,7 +1550,7 @@ xfrm_state_ok(struct xfrm_tmpl *tmpl, st
 	      unsigned short family)
 {
 	if (xfrm_state_kern(x))
-		return tmpl->optional && !xfrm_state_addr_cmp(tmpl, x, family);
+		return tmpl->optional && !xfrm_state_addr_cmp(tmpl, x, tmpl->encap_family);
 	return	x->id.proto == tmpl->id.proto &&
 		(x->id.spi == tmpl->id.spi || !tmpl->id.spi) &&
 		(x->props.reqid == tmpl->reqid || !tmpl->reqid) &&
-- 
1.4.1


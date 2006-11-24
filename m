From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][1/7] inter address family ipsec tunnel
Date: Fri, 24 Nov 2006 14:38:07 +0900
Message-ID: <20061124143807.5c4aa686.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:18905 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S934357AbWKXFny
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 00:43:54 -0500
To: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds encapsulation family.

Signed-off-by: Miika Komu <miika@iki.fi>
Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>

---
 include/net/xfrm.h     |    2 ++
 net/xfrm/xfrm_policy.c |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 3878a88..17e1924 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -310,6 +310,8 @@ struct xfrm_tmpl
 /* Source address of tunnel. Ignored, if it is not a tunnel. */
 	xfrm_address_t		saddr;
 
+	unsigned short		encap_family;
+
 	__u32			reqid;
 
 /* Mode: transport, tunnel etc. */
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index e5ea134..64d3938 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1211,6 +1211,7 @@ xfrm_tmpl_resolve_one(struct xfrm_policy
 		if (tmpl->mode == XFRM_MODE_TUNNEL) {
 			remote = &tmpl->id.daddr;
 			local = &tmpl->saddr;
+			family = tmpl->encap_family;
 			if (xfrm_addr_any(local, family)) {
 				error = xfrm_get_saddr(&tmp, remote, family);
 				if (error)

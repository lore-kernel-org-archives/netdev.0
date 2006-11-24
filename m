From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [PATCH][IPSEC][2/7] inter address family ipsec tunnel
Date: Fri, 24 Nov 2006 14:38:17 +0900
Message-ID: <20061124143817.389bac05.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:63390 "EHLO
	miyazawa.org") by vger.kernel.org with ESMTP id S934386AbWKXFnz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 00:43:55 -0500
To: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds netlink interface of the family

Signed-off-by: Miika Komu <miika@iki.fi>
Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>

---
 net/xfrm/xfrm_user.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 1598bf6..1d1b0dc 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -861,6 +861,7 @@ static void copy_templates(struct xfrm_p
 	int i;
 
 	xp->xfrm_nr = nr;
+	xp->family = ut->family;
 	for (i = 0; i < nr; i++, ut++) {
 		struct xfrm_tmpl *t = &xp->xfrm_vec[i];
 
@@ -874,6 +875,7 @@ static void copy_templates(struct xfrm_p
 		t->aalgos = ut->aalgos;
 		t->ealgos = ut->ealgos;
 		t->calgos = ut->calgos;
+		t->encap_family = ut->family;
 	}
 }
 
@@ -1027,7 +1029,7 @@ static int copy_to_user_tmpl(struct xfrm
 		struct xfrm_tmpl *kp = &xp->xfrm_vec[i];
 
 		memcpy(&up->id, &kp->id, sizeof(up->id));
-		up->family = xp->family;
+		up->family = kp->encap_family;
 		memcpy(&up->saddr, &kp->saddr, sizeof(up->saddr));
 		up->reqid = kp->reqid;
 		up->mode = kp->mode;



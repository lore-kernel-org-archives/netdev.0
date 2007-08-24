From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH] [XFRM] : Fix pointer copy size for encap_tmpl and coaddr.
Date: Fri, 24 Aug 2007 19:05:20 +0900
Message-ID: <11879499202750-git-send-email-nakam@linux-ipv6.org>
References: <20070822145632.087638328@lsx.localdomain>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
To: tgraf@suug.ch, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:44438 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755630AbXHXKFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 06:05:22 -0400
In-Reply-To: <20070822145632.087638328@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is minor fix about sizeof argument using with kmemdup().

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/xfrm/xfrm_user.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 0b8491f..46076f5 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -299,14 +299,14 @@ static struct xfrm_state *xfrm_state_construct(struct xfrm_usersa_info *p,
 
 	if (attrs[XFRMA_ENCAP]) {
 		x->encap = kmemdup(nla_data(attrs[XFRMA_ENCAP]),
-				   sizeof(x->encap), GFP_KERNEL);
+				   sizeof(*x->encap), GFP_KERNEL);
 		if (x->encap == NULL)
 			goto error;
 	}
 
 	if (attrs[XFRMA_COADDR]) {
 		x->coaddr = kmemdup(nla_data(attrs[XFRMA_COADDR]),
-				    sizeof(x->coaddr), GFP_KERNEL);
+				    sizeof(*x->coaddr), GFP_KERNEL);
 		if (x->coaddr == NULL)
 			goto error;
 	}
-- 
1.4.4.2


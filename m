From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net v1] ipv6/ila: fix nlsize calculation for lwtunnel
Date: Tue,  3 May 2016 09:58:27 +0200
Message-ID: <1462262307-27498-1-git-send-email-nicolas.dichtel@6wind.com>
References: <CALx6S36jkPqx5U+B9akRYZ+xiRhozk_AdOmKBEr4N9mhwTKQMw@mail.gmail.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Tom Herbert <tom@herbertland.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:34049 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbcECH6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 03:58:42 -0400
In-Reply-To: <CALx6S36jkPqx5U+B9akRYZ+xiRhozk_AdOmKBEr4N9mhwTKQMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The handler 'ila_fill_encap_info' adds one attribute: ILA_ATTR_LOCATOR.

Fixes: 65d7ab8de582 ("net: Identifier Locator Addressing module")
CC: Tom Herbert <tom@herbertland.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

RFC -> v1:
  - rebase on last net tree

 net/ipv6/ila/ila_lwt.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/ila/ila_lwt.c b/net/ipv6/ila/ila_lwt.c
index 2ae3c4fd8aab..41f18de5dcc2 100644
--- a/net/ipv6/ila/ila_lwt.c
+++ b/net/ipv6/ila/ila_lwt.c
@@ -120,8 +120,7 @@ nla_put_failure:
 
 static int ila_encap_nlsize(struct lwtunnel_state *lwtstate)
 {
-	/* No encapsulation overhead */
-	return 0;
+	return nla_total_size(sizeof(u64)); /* ILA_ATTR_LOCATOR */
 }
 
 static int ila_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
-- 
2.8.1

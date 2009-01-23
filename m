From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH] af_key: initialize xfrm encap_oa
Date: Fri, 23 Jan 2009 14:30:28 +0200
Message-ID: <1232713828-6725-1-git-send-email-timo.teras@iki.fi>
Cc: Timo Teras <timo.teras@iki.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:38488 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353AbZAWMae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 07:30:34 -0500
Received: by fk-out-0910.google.com with SMTP id f33so1215622fkf.5
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2009 04:30:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently encap_oa is left uninitialized, so it contains garbage data which
is visible to userland via Netlink. Initialize it by zeroing it out.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/key/af_key.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index f8bd8df..7dcbde3 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1285,6 +1285,7 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
 				ext_hdrs[SADB_X_EXT_NAT_T_DPORT-1];
 			natt->encap_dport = n_port->sadb_x_nat_t_port_port;
 		}
+		memset(&natt->encap_oa, 0, sizeof(natt->encap_oa));
 	}
 
 	err = xfrm_init_state(x);
-- 
1.5.6.3


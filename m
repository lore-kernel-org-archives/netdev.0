From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/6] af_key: constify lookup tables
Date: Thu, 22 Aug 2013 13:12:06 +0200
Message-ID: <1377169931-7302-3-git-send-email-steffen.klassert@secunet.com>
References: <1377169931-7302-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51100 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852Ab3HVLMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 07:12:34 -0400
In-Reply-To: <1377169931-7302-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>

The lookup tables for minimum sizes of extensions and for the pfkey
handler functions are read only, therefore can be const.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/key/af_key.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 4089a21..d49f676 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -338,7 +338,7 @@ static int pfkey_error(const struct sadb_msg *orig, int err, struct sock *sk)
 	return 0;
 }
 
-static u8 sadb_ext_min_len[] = {
+static const u8 sadb_ext_min_len[] = {
 	[SADB_EXT_RESERVED]		= (u8) 0,
 	[SADB_EXT_SA]			= (u8) sizeof(struct sadb_sa),
 	[SADB_EXT_LIFETIME_CURRENT]	= (u8) sizeof(struct sadb_lifetime),
@@ -2737,7 +2737,7 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, const struct sad
 
 typedef int (*pfkey_handler)(struct sock *sk, struct sk_buff *skb,
 			     const struct sadb_msg *hdr, void * const *ext_hdrs);
-static pfkey_handler pfkey_funcs[SADB_MAX + 1] = {
+static const pfkey_handler pfkey_funcs[SADB_MAX + 1] = {
 	[SADB_RESERVED]		= pfkey_reserved,
 	[SADB_GETSPI]		= pfkey_getspi,
 	[SADB_UPDATE]		= pfkey_add,
-- 
1.7.9.5

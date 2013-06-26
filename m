From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 2/2] af_key: constify lookup tables
Date: Wed, 26 Jun 2013 23:56:59 +0200
Message-ID: <1372283819-30012-3-git-send-email-minipli@googlemail.com>
References: <1372283819-30012-1-git-send-email-minipli@googlemail.com>
Cc: Mathias Krause <minipli@googlemail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:40575 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625Ab3FZV5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 17:57:13 -0400
Received: by mail-bk0-f41.google.com with SMTP id jc3so5237454bkc.28
        for <netdev@vger.kernel.org>; Wed, 26 Jun 2013 14:57:11 -0700 (PDT)
In-Reply-To: <1372283819-30012-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lookup tables for minimum sizes of extensions and for the pfkey
handler functions are read only, therefore can be const.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/key/af_key.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 5490d97..8432eb1 100644
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
@@ -2734,7 +2734,7 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, const struct sad
 
 typedef int (*pfkey_handler)(struct sock *sk, struct sk_buff *skb,
 			     const struct sadb_msg *hdr, void * const *ext_hdrs);
-static pfkey_handler pfkey_funcs[SADB_MAX + 1] = {
+static const pfkey_handler pfkey_funcs[SADB_MAX + 1] = {
 	[SADB_RESERVED]		= pfkey_reserved,
 	[SADB_GETSPI]		= pfkey_getspi,
 	[SADB_UPDATE]		= pfkey_add,
-- 
1.7.10.4

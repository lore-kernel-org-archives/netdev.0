From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netlink: Remove max_size setting
Date: Fri, 1 May 2015 08:27:59 +0800
Message-ID: <20150501002759.GA31660@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:60367 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbbEAA2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 20:28:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently limit the hash table size to 64K which is very bad
as even 10 years ago it was relatively easy to generate millions
of sockets.

Since the hash table is naturally limited by memory allocation
failure, we don't really need an explicit limit so this patch
removes it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ec4adbd..daa0b81 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -3139,7 +3139,6 @@ static const struct rhashtable_params netlink_rhashtable_params = {
 	.key_len = netlink_compare_arg_len,
 	.obj_hashfn = netlink_hash,
 	.obj_cmpfn = netlink_compare,
-	.max_size = 65536,
 	.automatic_shrinking = true,
 };
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

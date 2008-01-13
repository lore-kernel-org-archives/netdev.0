From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [FIB]: removes a memset() call in tnode_new()
Date: Sun, 13 Jan 2008 08:35:07 +0100
Message-ID: <4789BF2B.3040103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070702060300080801090607"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:52241 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbYAMHfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 02:35:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070702060300080801090607
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

tnode_alloc() already clears allocated memory, using kcalloc()
or alloc_pages(GFP_KERNEL|__GFP_ZERO, ...)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------070702060300080801090607
Content-Type: text/plain;
 name="fib_trie.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fib_trie.patch"

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index a418498..f26ba31 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -391,7 +391,6 @@ static struct tnode* tnode_new(t_key key, int pos, int bits)
 	struct tnode *tn = tnode_alloc(sz);
 
 	if (tn) {
-		memset(tn, 0, sz);
 		tn->parent = T_TNODE;
 		tn->pos = pos;
 		tn->bits = bits;

--------------070702060300080801090607--

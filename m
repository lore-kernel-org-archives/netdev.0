From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: netlink: Kill bogus lock_sock in netlink_insert
Date: Thu, 14 May 2015 14:02:30 +0800
Message-ID: <20150514060230.GD6058@gondor.apana.org.au>
References: <1431522271.566.132.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431533884.566.148.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514025333.GA3853@gondor.apana.org.au>
 <1431573463.27831.32.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514033448.GA5080@gondor.apana.org.au>
 <1431575890.27831.34.camel@edumazet-glaptop2.roam.corp.google.com>
 <1431576818.27831.36.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150514041628.GA5428@gondor.apana.org.au>
 <20150514042151.GA5482@gondor.apana.org.au>
 <20150514055824.GB6058@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>,
	Ying Xue <ying.xue@windriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:57072 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754929AbbENGCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 02:02:39 -0400
Content-Disposition: inline
In-Reply-To: <20150514055824.GB6058@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 01:58:24PM +0800, Herbert Xu wrote:
> 
> This patch also removes a bogus socket lock introduced by that
> very same patch.

This bogus socket lock is still there in the current tree.

---8<---
The commit c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink:
eliminate nl_sk_hash_lock") added a lock_sock to netlink_insert
with no justifications whatsoever.

This patch kills it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ec4adbd..9460561 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1063,8 +1063,6 @@ static int netlink_insert(struct sock *sk, u32 portid)
 	struct netlink_table *table = &nl_table[sk->sk_protocol];
 	int err;
 
-	lock_sock(sk);
-
 	err = -EBUSY;
 	if (nlk_sk(sk)->portid)
 		goto err;
@@ -1085,7 +1083,6 @@ static int netlink_insert(struct sock *sk, u32 portid)
 	}
 
 err:
-	release_sock(sk);
 	return err;
 }
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

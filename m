From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.9-rc2-mm2 fn_hash_insert oops
Date: Thu, 23 Sep 2004 21:16:32 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <E1CARaS-00071j-00@gondolin.me.apana.org.au>
References: <20040923103723.GA12145@mail.muni.cz>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268399AbUIWLQx@vger.kernel.org>
To: xhejtman@mail.muni.cz (Lukas Hejtmanek)
In-Reply-To: <20040923103723.GA12145@mail.muni.cz>
List-Id: netdev.vger.kernel.org

Lukas Hejtmanek <xhejtman@mail.muni.cz> wrote:
> 
> However there is still the issue with endless loop in fn_hash_delete :(

Same problem, same fix.  Can someone think of a generic fix to
list_for_each_*?

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/ipv4/fib_hash.c 1.22 vs edited =====
--- 1.22/net/ipv4/fib_hash.c	2004-09-22 09:31:48 +10:00
+++ edited/net/ipv4/fib_hash.c	2004-09-23 21:16:04 +10:00
@@ -608,6 +608,7 @@
 	struct fn_hash *table = (struct fn_hash*)tb->tb_data;
 	struct fib_node *f;
 	struct fib_alias *fa, *fa_to_delete;
+	struct list_head *fa_head;
 	int z = r->rtm_dst_len;
 	struct fn_zone *fz;
 	u32 key;
@@ -633,7 +634,8 @@
 		return -ESRCH;
 
 	fa_to_delete = NULL;
-	list_for_each_entry(fa, fa->fa_list.prev, fa_list) {
+	fa_head = fa->fa_list.prev;
+	list_for_each_entry(fa, fa_head, fa_list) {
 		struct fib_info *fi = fa->fa_info;
 
 		if ((!r->rtm_type ||

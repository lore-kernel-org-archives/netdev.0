From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Oops when stopping IPsec connection
Date: Fri, 24 Sep 2004 08:05:33 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CAbiX-00016Q-00@gondolin.me.apana.org.au>
References: <1095975655.5976.13.camel@pegasus>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: marcel@holtmann.org (Marcel Holtmann)
In-Reply-To: <1095975655.5976.13.camel@pegasus>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Marcel Holtmann <marcel@holtmann.org> wrote:
> EIP is at fib_nh_match+0x58/0x61
>
> Call Trace:
> [<c02680dd>] fn_hash_delete+0x231/0x243
> [<c02657d1>] inet_rtm_delroute+0x66/0x7a

Does this patch help?
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

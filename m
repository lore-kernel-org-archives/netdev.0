From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [patch-kj] net/ipv4/fib_hash.c: check kmem_cache_create()
Date: Tue, 22 Jun 2004 03:21:38 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040622.032138.58652005.yoshfuji@linux-ipv6.org>
References: <20040621171832.GE1545@sputnik.stro.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: romieu@fr.zoreil.com, janitor@sternwelten.at
In-Reply-To: <20040621171832.GE1545@sputnik.stro.at>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040621171832.GE1545@sputnik.stro.at> (at Mon, 21 Jun 2004 19:18:32 +0200), maximilian attems <janitor@sternwelten.at> says:

> From: Francois Romieu <romieu@fr.zoreil.com>
> 
> kmem_cache_create leak.
> 
> Note: fib_hash_init() can be called many times.
> 
> Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

Please tell us what kind of leakage do you see?
Is it just enough to return NULL if kmem_cache_create() fails
like this?

--- a/net/ipv4/fib_hash.c	10 Nov 2003 23:40:57 -0000	1.1.1.13
+++ b/net/ipv4/fib_hash.c	21 Jun 2004 18:19:16 -0000
@@ -871,12 +871,14 @@
 {
 	struct fib_table *tb;
 
-	if (fn_hash_kmem == NULL)
+	if (fn_hash_kmem == NULL) {
 		fn_hash_kmem = kmem_cache_create("ip_fib_hash",
 						 sizeof(struct fib_node),
 						 0, SLAB_HWCACHE_ALIGN,
 						 NULL, NULL);
-
+		if (fn_hash_kmem == NULL)
+			return NULL;
+	}
 	tb = kmalloc(sizeof(struct fib_table) + sizeof(struct fn_hash), GFP_KERNEL);
 	if (tb == NULL)
 		return NULL;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

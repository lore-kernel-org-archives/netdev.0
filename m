From: David Gibson <david@gibson.dropbear.id.au>
Subject: [TRIVIAL] Fix recent bug in fib_semantics.c
Date: Fri, 17 Sep 2004 16:20:42 +1000
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040917062042.GE6523@zax>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@redhat.com>, trivial@rustcorp.com.au,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S268435AbUIQGdY@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Andrew, please apply:

When fib_create_info() allocates new hash tables, it neglects to
initialize them.  This leads to an oops during boot on at least
machine I use.  This patch addresses the problem.

Signed-off-by: David Gibson <dwg@au1.ibm.com>

Index: working-2.6/net/ipv4/fib_semantics.c
===================================================================
--- working-2.6.orig/net/ipv4/fib_semantics.c	2004-09-17 09:20:04.000000000 +1000
+++ working-2.6/net/ipv4/fib_semantics.c	2004-09-17 16:24:42.634638304 +1000
@@ -604,8 +604,12 @@
 		if (!new_info_hash || !new_laddrhash) {
 			fib_hash_free(new_info_hash, bytes);
 			fib_hash_free(new_laddrhash, bytes);
-		} else
+		} else {
+			memset(new_info_hash, 0, bytes);
+			memset(new_laddrhash, 0, bytes);
+
 			fib_hash_move(new_info_hash, new_laddrhash, new_size);
+		}
 
 		if (!fib_hash_size)
 			goto failure;



-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson

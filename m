From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH,resent] reduce sizeof(struct inet_peer) from 128 to 64 bytes
 on 64bits architectures
Date: Thu, 17 Mar 2005 00:38:48 +0100
Message-ID: <4238C388.5040303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060101080702030703080106"
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060101080702030703080106
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Resent with diff file not tab/space mangled :(

As peer_cachep uses kmem_cache_create("inet_peer_cache", ... SLAB_HWCACHE_ALIGN ...),
better try to use exactly 64 bytes instead of 72 for struct inet_peer.

This also means that this structure fits in one cache line on x86_64.


Thank you
Eric Dumazet



--------------060101080702030703080106
Content-Type: text/plain;
 name="diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="diff"

diff -Nru linux-2.6.11/include/net/inetpeer.h linux-2.6.11-ed/include/net/inetpeer.h
--- linux-2.6.11/include/net/inetpeer.h	2005-03-02 08:37:48.000000000 +0100
+++ linux-2.6.11-ed/include/net/inetpeer.h	2005-03-16 18:52:49.000000000 +0100
@@ -19,9 +19,9 @@
 {
 	struct inet_peer	*avl_left, *avl_right;
 	struct inet_peer	*unused_next, **unused_prevp;
-	atomic_t		refcnt;
 	unsigned long		dtime;		/* the time of last use of not
 						 * referenced entries */
+	atomic_t		refcnt;
 	__u32			v4daddr;	/* peer's address */
 	__u16			avl_height;
 	__u16			ip_id_count;	/* IP ID for the next packet */

--------------060101080702030703080106--

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [27/*] [NET] Make dst_allfrag use dst instead of dst->path
Date: Fri, 18 Mar 2005 22:28:04 +1100
Message-ID: <20050318112804.GA6930@gondor.apana.org.au>
References: <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050318090310.GA28443@gondor.apana.org.au> <20050318091129.GA28658@gondor.apana.org.au> <20050318091918.GA28944@gondor.apana.org.au> <20050318100757.GA29433@gondor.apana.org.au> <20050318101126.GA29583@gondor.apana.org.au> <20050318110611.GA5843@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050318110611.GA5843@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Mar 18, 2005 at 10:06:11PM +1100, herbert wrote:
> 
> BTW, shouldn't dst_allfrag be called dst_path_allfrag?

Rather than doing that, let's make the path usage explicit in
the one place that it's needed (the same place where we use
dst_mtu(dst->path)).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Hmm, it still doesn't feel right to have an IPv6-specific helper
in net/dst.h.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-27

--- linux-2.6/include/net/dst.h.orig	2005-03-18 22:20:39.000000000 +1100
+++ linux-2.6/include/net/dst.h	2005-03-18 22:20:46.000000000 +1100
@@ -122,7 +122,7 @@
 static inline u32
 dst_allfrag(const struct dst_entry *dst)
 {
-	int ret = dst_metric(dst->path, RTAX_FEATURES) & RTAX_FEATURE_ALLFRAG;
+	int ret = dst_metric(dst, RTAX_FEATURES) & RTAX_FEATURE_ALLFRAG;
 	/* Yes, _exactly_. This is paranoia. */
 	barrier();
 	return ret;
--- linux-2.6/net/ipv6/ip6_output.c.orig	2005-03-18 22:21:01.000000000 +1100
+++ linux-2.6/net/ipv6/ip6_output.c	2005-03-18 22:23:52.000000000 +1100
@@ -851,7 +851,7 @@
 		inet->cork.fl = *fl;
 		np->cork.hop_limit = hlimit;
 		inet->cork.fragsize = mtu = dst_mtu(rt->u.dst.path);
-		if (dst_allfrag(&rt->u.dst))
+		if (dst_allfrag(rt->u.dst.path))
 			inet->cork.flags |= IPCORK_ALLFRAG;
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;

--DocE+STaALJfprDB--

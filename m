From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] add missing flow_cache_genid update to xfrm_policy_delete()
Date: Fri, 6 Aug 2004 07:24:21 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040805212421.GA4689@gondor.apana.org.au>
References: <20040805071459.GA31551@gate.ebshome.net> <E1BsgwG-0000O6-00@gondolin.me.apana.org.au> <20040805160144.GA28597@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gKMricLos+KVdGMg"
Cc: "David S. Miller" <davem@redhat.com>, Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040805160144.GA28597@gate.ebshome.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Aug 05, 2004 at 09:01:44AM -0700, Eugene Surovegin wrote:
> On Thu, Aug 05, 2004 at 10:01:40PM +1000, Herbert Xu wrote:
> > Please add a dir < XFRM_POLICY_MAX check before the atomic_inc so that
> > dying sockets with policies don't blow away the flow cache.
> 
> Ohh, you're right :). Updated patch follows.

Thanks.

Dave, please apply Eugene's patch to fix hard policy expiration.

Signed-off-by: Eugene Surovegin <ebs@ebshome.net>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/xfrm/xfrm_policy.c 1.52 vs edited =====
--- 1.52/net/xfrm/xfrm_policy.c	2004-07-23 13:23:33 -07:00
+++ edited/net/xfrm/xfrm_policy.c	2004-08-05 08:58:22 -07:00
@@ -536,8 +536,11 @@
 	write_lock_bh(&xfrm_policy_lock);
 	pol = __xfrm_policy_unlink(pol, dir);
 	write_unlock_bh(&xfrm_policy_lock);
-	if (pol)
+	if (pol) {
+		if (dir < XFRM_POLICY_MAX)
+			atomic_inc(&flow_cache_genid);
 		xfrm_policy_kill(pol);
+	}
 }
 
 int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)

--gKMricLos+KVdGMg--

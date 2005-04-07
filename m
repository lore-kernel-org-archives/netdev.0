From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/*] [NET] Shave 8 bytes off dst_entry on 64-bit
Date: Thu, 7 Apr 2005 23:25:23 +1000
Message-ID: <20050407132523.GA20795@gondor.apana.org.au>
References: <20050407121839.GA9641@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050407121839.GA9641@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Apr 07, 2005 at 10:18:39PM +1000, herbert wrote:
> 
> This rearranges dst_entry so that we shave off 8 bytes on 64-bit
> platforms when CLS_ROUTE is enabled.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> I'll rearrange rtable next which will save us some more.

Unfortunately that turned out to be a nightmare due to the
way rt_flags is used.

So I came back to dst_entry to look for things to axe :)

So instead of moving error down let's move it up and shrink
it and obsolete which saves a pointer width on both 32-bit
and 64-bit platforms.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Please note that this is NOT incremental to the last patch.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=route-2

===== include/net/dst.h 1.32 vs edited =====
--- 1.32/include/net/dst.h	2005-03-19 05:44:52 +11:00
+++ edited/include/net/dst.h	2005-04-07 23:24:19 +10:00
@@ -42,7 +42,8 @@
 	int			__use;
 	struct dst_entry	*child;
 	struct net_device       *dev;
-	int			obsolete;
+	short			error;
+	short			obsolete;
 	int			flags;
 #define DST_HOST		1
 #define DST_NOXFRM		2
@@ -60,8 +61,6 @@
 
 	unsigned long		rate_last;	/* rate limiting for ICMP */
 	unsigned long		rate_tokens;
-
-	int			error;
 
 	struct neighbour	*neighbour;
 	struct hh_cache		*hh;

--VS++wcV0S1rZb1Fb--

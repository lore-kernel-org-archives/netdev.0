From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] Use add_timer instead of mod_timer in find_acq
Date: Tue, 25 May 2004 22:10:55 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040525121055.GA15690@gondor.apana.org.au>
References: <20040524115357.GA28827@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zYM0uCDKw75PZbzx"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040524115357.GA28827@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, May 24, 2004 at 09:53:57PM +1000, herbert wrote:
> 
> Here is a tiny optimisation to use add_timer instead of mod_timer
> on the create path in find_acq.

Here is the same optimisation for the creation path in xfrm_state_find.
It also fixes the timer so that it actually expires :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/xfrm/xfrm_state.c 1.41 vs edited =====
--- 1.41/net/xfrm/xfrm_state.c	2004-05-25 22:01:18 +10:00
+++ edited/net/xfrm/xfrm_state.c	2004-05-25 22:09:10 +10:00
@@ -345,7 +345,8 @@
 			}
 			x->lft.hard_add_expires_seconds = XFRM_ACQ_EXPIRES;
 			xfrm_state_hold(x);
-			mod_timer(&x->timer, XFRM_ACQ_EXPIRES*HZ);
+			x->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
+			add_timer(&x->timer);
 		} else {
 			x->km.state = XFRM_STATE_DEAD;
 			xfrm_state_put(x);

--zYM0uCDKw75PZbzx--

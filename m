From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Fri, 8 Apr 2005 15:48:31 +1000
Message-ID: <20050408054831.GA569@gondor.apana.org.au>
References: <Pine.LNX.4.58.0504051925250.21486@graphe.net> <E1DJ5y2-0003rF-00@gondolin.me.apana.org.au> <20050406111721.3ac67605.davem@davemloft.net> <20050407110724.GA8760@gondor.apana.org.au> <Pine.LNX.4.58.0504070842420.29731@graphe.net> <20050407212504.GA4939@gondor.apana.org.au> <Pine.LNX.4.58.0504072221190.11242@graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        pravins@calsoftinc.com, shai@scalesx86.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Lameter <christoph@lameter.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0504072221190.11242@graphe.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 07, 2005 at 10:45:02PM -0700, Christoph Lameter wrote:
>
> +			atomic_dec(&dst->__refcnt);
> +			smp_mb__after_atomic_dec();
> +			if (!atomic_read(&dst->__refcnt))
> +				/*
> +				 * There are no other references and therefore
> +				 * the dst can be freed now
> +				 */
>  				goto again;

This is wrong.  The barrier needs to be after the atomic_read.
Please see my patch to Dave.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

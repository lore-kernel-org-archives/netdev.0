From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pskb change in dst->output
Date: Thu, 8 Jul 2004 14:02:35 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040708040235.GA32678@gondor.apana.org.au>
References: <20040708011100.GA31600@gondor.apana.org.au> <Xine.LNX.4.44.0407072327390.29365-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0407072327390.29365-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 07, 2004 at 11:34:59PM -0400, James Morris wrote:
> 
> We need to pass a pointer to skb to skb->dst->output() because the skb can
> be changed by skb_checksum_help() in one of these output paths.  Further
> iteration would otherwise pass an incorrect (freed) skb.

That's only because the dst->output() functions are calling
skb_checksum_help().  Since those same functions assume the
skb to be "uncloned" anyway (they modify it directly by adding
headers etc.), they only need to call a version of
skb_checksum_help() that does not do a copy of the skb.

This is what dst->output() did before this change anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: pskb change in dst->output
Date: Wed, 7 Jul 2004 23:06:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707130652.GA26822@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi James:

I'm working on merging the IPsec tunnel encapsulation code so that
we have only one copy of it instead of four.

In doing so I'm wondering why you changed dst->output to take a
struct sk_buff ** from a struct sk_buff *.  All of the dst->output
functions already assumed that they have exclusive access to the skb.
This is justified because all callers to dst_output() makes sure that
the packet is neither shared nor cloned.

So in practice the calls to skb_checksum_help() from AH/ESP/IPCOMP
are never going to unshare the skb.  In that case, couldn't we just
have a version of skb_checksum_help() that was for the case where
the skb is never shared?

This would allow us to go back to the single pointer in dst->output.
The double pointer is also an eye sore because in most of these
dst->output functions, the first access to the skb after
skb_checksum_help() usually assumes that the skb is neither
shared nor cloned.

This is bad because someone in future could assume that dst->output
can take a shared/cloned skb based on the fact that it takes a
struct sk_buff **.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

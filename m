From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NAT-T] NON-IKE encapsulation
Date: Sat, 26 Jun 2004 07:57:47 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040625215747.GA14930@gondor.apana.org.au>
References: <20040624123603.GA1241@gondor.apana.org.au> <20040625101231.6f6b2f12.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: agruen@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040625101231.6f6b2f12.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 25, 2004 at 10:12:31AM -0700, David S. Miller wrote:
> 
> I now think it's trying to account for the udpdata32[] header area.
> But that's not 2 bytes, it's (2 * sizeof(u32)) or 8 bytes.

That's what I thought too, but that is already accounted by
x->props.header_len in init_state.

In any case, just increasing alen like that is wrong.  It needs to
do at least three other things:

1. Allocate memory for it in skb_cow_data.
2. Fill in those bytes with data so we don't leak information.
3. Teach get_max_size about it.

Andreas, can you please clarify for us as to what those two bytes
are for?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

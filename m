From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pskb change in dst->output
Date: Sat, 10 Jul 2004 07:07:01 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709210701.GA3281@gondor.apana.org.au>
References: <20040709081443.GA11101@gondor.apana.org.au> <Xine.LNX.4.44.0407091001460.3887-100000@thoron.boston.redhat.com> <20040709123608.1f9f9265.davem@redhat.com> <20040709204228.GA3015@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040709204228.GA3015@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jul 10, 2004 at 06:42:28AM +1000, herbert wrote:
> 
> So unless I've missed another case where someone will pass a clone
> down, it is safe to change the checksum on the TCP clones.

Please note that even if you decide at the API-level that it is not
OK for dst->output() functions to modify anything beyond the IP
headers, we still don't need to copy the entire skb.

Since it's already a clone anyway, skb_cow() suffices to allow
changing the checksum.

Is there a situation where someone will pass a shared (not cloned) skb
down on the netfilter path? If not, then we can do skb_cow() there as
well.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV6] Fix dst leak in ipv6_add_addr
Date: Sat, 6 Nov 2004 19:20:57 +1100
Message-ID: <20041106082057.GA17707@gondor.apana.org.au>
References: <20041106044121.GA16397@gondor.apana.org.au> <20041106000518.75eca9b2.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041106000518.75eca9b2.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Nov 06, 2004 at 12:05:18AM -0800, David S. Miller wrote:
> On Sat, 6 Nov 2004 15:41:21 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > Found another error-path dst leak.  If the idev->dead check is
> > triggered in ipv6_add_addr the rt entry will leak.
> 
> This one was fixed in the xfrm_lookup() patch I sent yesterday :-)

Indeed, I overlooked that message :)

However your version still leaks the rt since its refcnt is set to 1.
It will also dereference an unitialised rt if allocating ifa fails.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

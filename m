From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 0/2] rhashtable: Add walk iterator primitives and use them in
 netlink
Date: Sat, 31 Jan 2015 14:13:56 +1100
Message-ID: <20150131031356.GA26781@gondor.apana.org.au>
References: <20150122084924.GA4720@gondor.apana.org.au>
 <20150125232040.GA17936@gondor.apana.org.au>
 <20150127231950.GA11374@gondor.apana.org.au>
 <20150129.144246.1383921666389409323.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, ying.xue@windriver.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150129.144246.1383921666389409323.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 29, 2015 at 02:42:46PM -0800, David Miller wrote:
> 
> I'm holding off on this series for now.
> 
> Let me know if you want me to do something different.

No problems.  Here is a new version of these two patches which
hopefully should work on netfilter as well.

Note that the major functional difference compared to the previous
one is that resizes are now handled properly and will cause the
iterator to restart from scratch.

However, as with all existing hash table walker implementations,
if you remove an element from the chain that we're walking over
while we're waiting for user-space to give us a new buffer, then
the walk may miss elements that are still on that chain.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

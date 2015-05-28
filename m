From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm6: Do not use xfrm_local_error for path MTU issues
 in tunnels
Date: Thu, 28 May 2015 12:49:19 +0800
Message-ID: <20150528044918.GA4333@gondor.apana.org.au>
References: <20150527173823.1415.96248.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150527173823.1415.96248.stgit@ahduyck-vm-fedora22>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 27, 2015 at 10:40:32AM -0700, Alexander Duyck wrote:
> This change makes it so that we use icmpv6_send to report PMTU issues back
> into tunnels in the case that the resulting packet is larger than the MTU
> of the outgoing interface.  Previously xfrm_local_error was being used in
> this case, however this was resulting in no changes, I suspect due to the
> fact that the tunnel itself was being kept out of the loop.
> 
> This patch fixes PMTU problems seen on ip6_vti tunnels and is based on the
> behavior seen if the socket was orphaned.  Instead of requiring the socket
> to be orphaned this patch simply defaults to using icmpv6_send in the case
> that the frame came though a tunnel.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Does this still work with normal tunnel mode and identical inner
and outer addresses? I recall we used to have a bug where in that
situation the kernel would interpret the ICMP message as a reduction
in outer MTU and thus resulting in a loop where the MTU keeps
getting smaller.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

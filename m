From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm6: Do not use xfrm_local_error for path MTU issues
 in tunnels
Date: Thu, 28 May 2015 07:36:08 +0200
Message-ID: <20150528053607.GF27342@secunet.com>
References: <20150527173823.1415.96248.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <herbert@gondor.apana.org.au>,
	<netdev@vger.kernel.org>, <linux-crypto@vger.kernel.org>
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

We can use icmpv6_send() just in the case that the packet
was already transmitted by a tunnel device, otherwise we
get the bug back that I mentioned in my other mail.

Not sure if we have something to know that the packet
traversed a tunnel device. That's what I asked in the
thread 'Looking for a lost patch'.

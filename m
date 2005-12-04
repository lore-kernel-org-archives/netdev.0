From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Mon, 5 Dec 2005 09:10:02 +1100
Message-ID: <20051204221002.GA17056@gondor.apana.org.au>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163135.16666.76993.sendpatchset@localhost.localdomain>
	<20051201012711.GA2527@gondor.apana.org.au>
	<4393684A.8030208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4393684A.8030208@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 04, 2005 at 11:06:02PM +0100, Patrick McHardy wrote:
>
> >I'm worried about this bit.  This looks like it'll go back to the top
> >of the IP stack with the existing call chain.  So could grow as the
> >number of transforms increase.
> 
> Its not so bad. It adds ip_xfrm_transport_hook and
> ip_local_deliver_finish to the call stack, but since two subsequent
> transport mode SAs are always processed at once it can't take this
> path again without calling netif_rx in between.

If there is a DNAT in the way, this will jump to the very start of
the stack.  So if we have a hostile IPsec peer, and the DNAT rules
are such that this can occur, then we could be in trouble (especially
because policy/selector verification does not occur until all IPsec
has been done so we can't check inner address validitiy at this point).
 
> Besides the double counting, packets also appear on the packet sockets
> after transport mode decapsulation with the original approach. For
> IPv6 there's also the double-parsing of extension header issue.

Having the packets appear twice on AF_PACKET is probably desirable :)

I'll need to think about the double-parsing though.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

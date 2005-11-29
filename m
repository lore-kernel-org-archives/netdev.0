From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 07/13]: [NETFILTER]: Fix xfrm lookup in
	ip_route_me_harder/ip6_route_me_harder
Date: Tue, 29 Nov 2005 18:34:41 +1100
Message-ID: <20051129073441.GA18387@gondor.apana.org.au>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163137.16666.924.sendpatchset@localhost.localdomain>
	<20051128210628.GA15057@gondor.apana.org.au>
	<438BFD0A.5040105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <438BFD0A.5040105@trash.net>
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

On Tue, Nov 29, 2005 at 08:02:34AM +0100, Patrick McHardy wrote:
> 
> - IPSKB_MASQUERADED is unused
> - IPSKB_TRANSLATED is unused
> - IPSKB_FORWARDED is used by ipmr in a way that looks broken,
>   it expects the flags on the input path to be the same it set
>   on the output path.
> - IPSKB_XFRM_TUNNEL_SIZE should be cleared when a packet enters
>   the IP stack

Yes that looks correct.

> It seems in most places where only IPCB(skb)->opt is cleared
> the entire CB should be cleared. A couple of spots also look
> completely unnecessary, for example all places clearing the CB
> before passing the packet to netif_rx. I would expect the next
> user beeing responsible for clearing the space he needs if
> neccessary.

Agreed.  However, it seems that ip_rcv() only clears the CB options
if ihl is greater than 5.  So until that's changed the people feeding
netif_rx will have to clear the CB.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

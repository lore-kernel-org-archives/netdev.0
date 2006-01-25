From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 5936] New: Openswan tunnels + netfilter
	problem
Date: Wed, 25 Jan 2006 20:57:46 +1100
Message-ID: <20060125095746.GA14753@gondor.apana.org.au>
References: <E1F1IYh-0001I3-00@gondolin.me.apana.org.au>
	<43D74407.5040705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	webmaster@elnportal.it
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <43D74407.5040705@trash.net>
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

On Wed, Jan 25, 2006 at 10:25:27AM +0100, Patrick McHardy wrote:
> 
> I don't like adding this special behaviour for NAT, people need
> to adjust their rulesets for filtering etc. anyway. We could stop
> rerouting packets in between transforms (when both dst->xfrm and
> IPSKB_XFRM_TRANSFORMED are set), but this is inconsistent with what
> happens on input, when a packet is DNATed in PRE_ROUTING it does

Actually we can never achieve perfect symmetry because the two cases
are fundamentally different.  On outbound we start with a template
which guides us all the way to the end.  On inbound we (currently)
don't determine the policy until the very end.

> affect the SA lookup. So I think I'd prefer handling this case in
> xfrm[46]_output_finish, but I need to think about it a bit more.

Having said that I'm certainly not averse to such a solution.  The
only thing I would like to see is for it to be flexible enough so
that you always get at least one chance to SNAT before the xfrm_policy
is completely pinned down.  This should leave the user with enough
flexibility to do whatever they wish.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

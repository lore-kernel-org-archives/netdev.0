From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Wed, 26 Oct 2005 01:09:12 +0200
Message-ID: <435EBB18.50701@trash.net>
References: <4352EEC8.9000602@trash.net>
	<20051017.094919.56989341.yoshfuji@linux-ipv6.org>
	<4352FD49.4090201@trash.net>
	<20051017014629.GB32661@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20051017014629.GB32661@gondor.apana.org.au>
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

Sorry for the huge delay Herbert, I really appreciate your input,
but I'm stuck in other work.

Herbert Xu wrote:
> I can see the concern of processing pure transport mode packets in IPv6
> twice in the stack because IPsec in IPv6 is used for a totally different
> purpose compared to IPv4.
> 
> So how about this? We let the SA tell us whether they want to go through
> netfilter again.  So each SA will carry a flag which determines whether
> packets through it should go through netfilter.
> 
> This flag would only affect transport mode SAs of course.

That would be one possibility. But I'm not a big fan of per-state flags
that affect packet flow, so I think I'd prefer to just ignore this
case. I don't think not handling inner transport mode SAs would be a
big loss, so how about we just skip inner transport mode SAs completely
on output and keep the input code as it is?

Regards
Patrick

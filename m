From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 02/10]: [NETFILTER]: Defer fragmentation in ip_output
	when connection tracking is used
Date: Tue, 15 Nov 2005 21:44:25 +1100
Message-ID: <20051115104425.GA31719@gondor.apana.org.au>
References: <43740DB5.9070206@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <43740DB5.9070206@trash.net>
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

On Fri, Nov 11, 2005 at 03:19:17AM +0000, Patrick McHardy wrote:

> [NETFILTER]: Defer fragmentation in ip_output when connection tracking is used
> 
> This allows to get rid of the okfn use in ip_refrag and save the useless
> fragmentation/defragmentation step when NAT is used.

I'm slightly uneasy about this change because for POST_ROUTING, the
defragmentation occurs in the middle of the hook, NF_IP_PRI_NAT_SRC.

This means that things like the mangle table currently sees the
fragments as opposed to the whole packet.  This patch will change
that.

Now I'm not saying that this is necessarily a bad thing.  In fact,
for all I know it might make more sense to do this.  But we should
consider the possible implications before embarking on it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

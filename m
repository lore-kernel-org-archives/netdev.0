From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Conntrack leak with raw sockets
Date: Sat, 26 Mar 2005 11:09:41 +1100
Message-ID: <E1DEys1-0005wu-00@gondolin.me.apana.org.au>
References: <4244766D.2020001@trash.net>
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
To: kaber@trash.net (Patrick McHardy)
In-Reply-To: <4244766D.2020001@trash.net>
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

Patrick McHardy <kaber@trash.net> wrote:
> 
> Great work tracking this down. But I fear the problem will come back
> haunt us with this patch. The are more places where a packet can be
> queued indefinitely, for example stopped qdiscs. IMO the best fix
> is to drop the conntrack reference once the packet leaves IP, so we
> don't have to make any assumptions about what will happen to the
> packet - this would be in ip_finish_output2(). Could you send a patch
> that does this? While you're at it, you could also remove this part
> from ip_conntrack_standalone:

Agreed.

BTW, please use nf_reset() instead of open coding this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Change masquerade code to use first IP address of
	interface.
Date: Wed, 20 Oct 2004 21:12:45 +1000
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041020111245.GA22703@gondor.apana.org.au>
References: <E1CKBtq-0005FC-00@gondolin.me.apana.org.au>
	<Pine.LNX.4.61.0410201123200.25590@filer.marasystems.com>
	<20041020104650.GA20868@gondor.apana.org.au>
	<Pine.LNX.4.61.0410201300580.28452@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Rusty Russell <rusty@rustcorp.com.au>,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Henrik Nordstrom <hno@marasystems.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0410201300580.28452@filer.marasystems.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 20, 2004 at 01:04:51PM +0200, Henrik Nordstrom wrote:
> On Wed, 20 Oct 2004, Herbert Xu wrote:
> 
> >I mean
> >
> >	rt = (struct rtable *)(*pskb)->dst;
> >	newsrc = inet_select_addr(out, rt->rt_gateway, RT_SCOPE_UNIVERSE);
> 
> IIRC we are not allowed to access this here, but I may be wrong.. If we 

Why? POST_ROUTING is called in three places in ip_output.c and they all
give a valid dst.  In fact ip_refrag in ip_conntrack_standalone.c is also
accessing skb->dst.

> are allowe to access the rtable like this then this is obviously better, 
> and should also solve most policy routing setups (and allow the others to 
> be solved).

Well it isn't really equivalent to full policy routing since we've lost
the preferred source field.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: "David S. Miller" <davem@davemloft.net>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Fri, 4 Feb 2005 22:13:44 -0800
Message-ID: <20050204221344.247548cb.davem@davemloft.net>
References: <20050131162201.GA1000@stilzchen.informatik.tu-chemnitz.de>
	<20050205052407.GA17266@gondor.apana.org.au>
	<20050204213813.4bd642ad.davem@davemloft.net>
	<20050205061110.GA18275@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mirko.parthey@informatik.tu-chemnitz.de, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, shemminger@osdl.org
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050205061110.GA18275@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 5 Feb 2005 17:11:10 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> You're right of course.  I thought they were all harmless but I was
> obviously wrong about this one.
> 
> So here is a patch that essentially reverts the split devices
> semantics introduced by these two changesets:
> 
>   [IPV6] addrconf_dst_alloc() to allocate new route for local address.
>   [IPV6] take rt6i_idev into account when looking up routes.
> 
> Signed-off-by: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>

Ok.

But Herbert, let's take a step back real quick because I want
to point something out.  IPv6 does try to handle the dangling
mismatched idev's, in route.c:ip6_dst_ifdown(), this is called
via net/core/dst.c:dst_ifdown(), and this releases the ipv6
idev correctly in the split device case.

Did your analysis of this bridging release bug take this into
account?  That's why we added this dst->ops method, specifically
to handle this problem.

This was added by Yoshifuji-san in ChangeSet 1.1722.137.17 which
has the checking comment:

[NET]: Add dst->ifdown callback.

Use it to release protocol specific objects that may be
tied to a dst cache object, at ifdown time.  Currently
this is used to release ipv4/ipv6 specific device state.

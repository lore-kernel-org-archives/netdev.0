From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BUG] overflow in net/ipv4/route.c rt_check_expire()
Date: Sat, 2 Apr 2005 11:55:28 -0800
Message-ID: <20050402115528.11f71a3c.davem@davemloft.net>
References: <E1DHdsP-0003Lr-00@gondolin.me.apana.org.au>
	<424E641A.1020609@cosmosbay.com>
	<16974.41648.568927.54429@robur.slu.se>
	<20050402193224.GA25157@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050402193224.GA25157@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 3 Apr 2005 05:32:24 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sat, Apr 02, 2005 at 03:48:32PM +0200, Robert Olsson wrote:
> >  
> >  > Crashes usually occurs when secret_interval interval is elapsed : rt_cache_flush(0); is called, and the whole machine begins to die.
> > 
> >  A good idea to increase the secret_interval interval but it should survive.
> 
> Incidentally we should change the way the rehashing is triggered.
> Instead of doing it regularly, we can do it when we notice that a
> specific hash chain grows beyond a certain size.
> 
> The idea is that if someone is attacking our hash then they can
> only do so by lengthening the chains.  If they're not doing that
> then even if they knew how to attack us we don't really care.

Yes, the secret_interval is way too short.  It is a very paranoid
default value selected when initially fixing that DoS.

I think we should, in the short term, increase the secret interval
where it exists in the tree (netfilter conntrack is another instance
for example).

From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.9-rc1+bk: assertion tcp_get_pcount failed at
 net/ipv4/tcp_input.c
Date: Thu, 9 Sep 2004 22:25:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909222542.7a30c0e4.davem@davemloft.net>
References: <20040909111233.GA3987@steel.home>
	<20040910033055.GA26790@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fork0@users.sourceforge.net, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040910033055.GA26790@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Sep 2004 13:30:55 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Sep 09, 2004 at 11:12:33AM +0000, Alex Riesen wrote:
> > The box froze after being left for some time (some 10 hours) unattended.
> > The only thing in I could find in logs was:
> > 
> > Sep  8 22:30:18 steel kernel: KERNEL: assertion ((int)tcp_get_pcount(&tp->lost_out) >= 0) failed at net/ipv4/tcp_input.c (2422)
> > Sep  8 22:30:18 steel kernel: Leak l=4294967295 4
> 
> Looks like the factor isn't set early enough.  Can you please check
> that you had the changeset titled
> 
> [TCP]: Make sure SKB tso factor is setup early enough.
> 
> from davem?
> 
> If you did, then please apply the following patch and tell us what
> the resulting messages.

Herbert did you see my division fix I made today for
tso_factor calculation?  I was dividing by the TSO mss
instead of the normal one :-)

I think that is the cause of these problems.  It was
definitely the cause of a BUG() trap hit in tcp_transmit_skb()
that someone else reported in the past day.

From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.9 failed assertion in tcp_timer.c
Date: Mon, 25 Oct 2004 21:09:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041025210946.367f65be.davem@davemloft.net>
References: <20041019215054.GA17565@linuxace.com>
	<E1CK3Az-0004P2-00@gondolin.me.apana.org.au>
	<20041020164748.GA20905@linuxace.com>
	<20041020212651.GA8534@gondor.apana.org.au>
	<20041020225536.GA22179@linuxace.com>
	<20041021130339.GA19345@gondor.apana.org.au>
	<20041021165224.GA25399@linuxace.com>
	<20041021215743.GA23062@gondor.apana.org.au>
	<20041022185435.GA30709@linuxace.com>
	<20041022215040.GA13309@gondor.apana.org.au>
	<20041022232403.GA14618@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kernel@linuxace.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041022232403.GA14618@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 23 Oct 2004 09:24:03 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Actually, I think we've caught your crash now.  If that code path
> is triggering at all, then it'll trigger with TSO packets too.  If
> we get a truly partial ack on a TSO packet, then tcp_tso_acked will
> not trim it off.  So we will fall through to this last-ditch trim
> call, which doesn't update packets_out.
> 
> There are two solutions to this problem.  I've taken the simpler
> approach for now.  We simply trim off the partial bits in tcp_tso_acked
> and live with the fact that the packet counters may differ from
> what's on the netwrok by one.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Later on we can "fix" this by remembering where the original TSO
> packet started from, perhaps in skb->h or somewhere.  Dave, is this
> worth it?

I'm going to apply this patch for now.

I think at this point we can generalize TSO processing a bit
better in this code now.

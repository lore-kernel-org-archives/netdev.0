From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: efficient port randomisation
Date: Mon, 1 Nov 2004 09:20:27 -0800
Message-ID: <20041101092027.2a741e82@zqx3.pdx.osdl.net>
References: <20041027092531.78fe438c@guest-251-240.pdx.osdl.net>
	<200410291048.01955.michael.vittrup.larsen@ericsson.com>
	<20041029102828.123502e7@zqx3.pdx.osdl.net>
	<200411011058.23141.michael.vittrup.larsen@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com>
In-Reply-To: <200411011058.23141.michael.vittrup.larsen@ericsson.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Nov 2004 11:58:23 +0200
Michael Vittrup Larsen <michael.vittrup.larsen@ericsson.com> wrote:

> On Friday 29 October 2004 19:28, Stephen Hemminger wrote:
> > Provide port randomization for incoming connections using variation of
> > existing sequence number hash. Replace tcp_portalloc_lock and
> > tcp_port_rover with atomic operation to allow better parallelism.
> >
> > This is based on
> > http://www.ietf.org/internet-drafts/draft-larsen-tsvwg-port-randomisation-0
> >0.txt (with confirmation of of no IPR issues).
> 
> I have looked through this, and have a few comments:
> 
> * It is probably a good strategy to set 'tcp_rover_next' such that
>   the next search is resumed from the previous port found to be free.
>   (similar to the old algorithm).  I don't see this in your patch,
>   but of course I could have missed it.

It was intentional since it would require holding a lock around the search. The tradeoff
is better SMP performance in the sparsely filled port space (more typical) vs.
better UP performance in the case of a mostly full port space.


> * connect_port_offset() does not (at least from an algorithm point
>   of view) need to return an u32, an u16 is sufficient.

If it is truncated to u16, then compiler has to take extra effort to truncate
is unnecessary given later  modulo operation.

> Michael Larsen

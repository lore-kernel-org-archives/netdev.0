From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] netem: account for packets in delayed queue in qlen
Date: Thu, 21 Apr 2005 13:20:20 +1000
Message-ID: <20050421132020.41858bc4@localhost.localdomain>
References: <20050329152110.38d50653@dxpl.pdx.osdl.net>
	<4252EB9D.9070305@trash.net>
	<20050407120417.4297cd14@dxpl.pdx.osdl.net>
	<42628300.9010007@trash.net>
	<20050419110639.47767113@localhost.localdomain>
	<42666098.5060409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42666098.5060409@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Apr 2005 16:00:56 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > There may be no sane way to do duplication without that.
> 
> This way doesn't work properly either. The classful qdiscs don't care
> about their own q.qlen and just try to dequeue, if successful they
> decrement q.qlen. When duplicating packets in an inner qdisc the
> top-level qdisc's q.qlen will turn negative at some point (it's
> unsigned, but returned as int from qdisc_restart) and will cause
> qdisc_run() to spin forever.

So duplication is a no go...
Unless there is a different way of accounting for qlen (like a callback).

> > Other ways like injecting
> > packets again at top of queue with a thread/tasklet seem rather gross
> 
> Injecting at the top is also problematic because it needs to
> follow the same classification-path as the first packet, which
> can only be guarenteed with stateless classification.
> 
> Regards
> Patrick

From: Shaohua Li <shli@kernel.org>
Subject: Re: [RFC net-next] net ipv6: convert fib6_table rwlock to a percpu
 lock
Date: Mon, 31 Jul 2017 19:57:04 -0700
Message-ID: <20170801025704.fuhxll23d3eenwrz@kernel.org>
References: <1a5ad2f0585aa66496b27e123d1c38b75552df4c.1501520674.git.shli@fb.com>
 <20170731161007.61c2d958@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, Kernel-team@fb.com,
        Shaohua Li <shli@fb.com>, Wei Wang <weiwan@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:46918 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751809AbdHAC5G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 22:57:06 -0400
Content-Disposition: inline
In-Reply-To: <20170731161007.61c2d958@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 04:10:07PM -0700, Stephen Hemminger wrote:
> On Mon, 31 Jul 2017 10:18:57 -0700
> Shaohua Li <shli@kernel.org> wrote:
> 
> > From: Shaohua Li <shli@fb.com>
> > 
> > In a syn flooding test, the fib6_table rwlock is a significant
> > bottleneck. While converting the rwlock to rcu sounds straighforward,
> > but is very challenging if it's possible. A percpu spinlock is quite
> > trival for this problem since updating the routing table is a rare
> > event. In my test, the server receives around 1.5 Mpps in syn flooding
> > test without the patch in a dual sockets and 56-CPU system. With the
> > patch, the server receives around 3.8Mpps, and perf report doesn't show
> > the locking issue.
> > 
> > Cc: Wei Wang <weiwan@google.com>
> 
> You just reinvented brlock...

you mean lglock? It has been removed from kernel.
 
> RCU is not that hard, why not do it right?

Maybe. But don't think it's the reason why we shouldn't do the percpu lock now,
this is a simple change, if some smart guys find a way of RCU, we can easily
remove this.

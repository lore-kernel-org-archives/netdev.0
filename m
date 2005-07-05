From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Wed, 6 Jul 2005 01:55:04 +0200
Message-ID: <20050705235504.GS16076@postel.suug.ch>
References: <20050705.143548.28788459.davem@davemloft.net> <42CB14B2.5090601@cosmosbay.com> <20050705234104.GR16076@postel.suug.ch> <20050705.164503.104035718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050705.164503.104035718.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050705.164503.104035718.davem@davemloft.net> 2005-07-05 16:45
> From: Thomas Graf <tgraf@suug.ch>
> Date: Wed, 6 Jul 2005 01:41:04 +0200
> 
> > I still think we can fix this performance issue without manually
> > unrolling the loop or we should at least try to. In the end gcc
> > should notice the constant part of the loop and move it out so
> > basically the only difference should the additional prio++ and
> > possibly a failing branch prediction.
> 
> But the branch prediction is where I personally think a lot
> of the lossage is coming from.  These can cost upwards of 20
> or 30 processor cycles, easily.  That's getting close to the
> cost of a L2 cache miss.

Absolutely. I think what happens is that we produce predicion
failures due to the logic within qdisc_dequeue_head(), I
cannot back this up with numbers though.

> I see the difficulties with this change now, why don't we revisit
> this some time in the future?

Fine with me.

Eric, the patch I just posted should result in the same branch
prediction as your loop unrolling. The only additional overhead
we still have is the list + prio thing and an additional conditional
jump to do the loop. If you have the cycles etc. it would be nice
to compare it with your numbers.

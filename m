From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Tue, 05 Jul 2005 16:45:03 -0700 (PDT)
Message-ID: <20050705.164503.104035718.davem@davemloft.net>
References: <20050705.143548.28788459.davem@davemloft.net>
	<42CB14B2.5090601@cosmosbay.com>
	<20050705234104.GR16076@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch
In-Reply-To: <20050705234104.GR16076@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 6 Jul 2005 01:41:04 +0200

> I still think we can fix this performance issue without manually
> unrolling the loop or we should at least try to. In the end gcc
> should notice the constant part of the loop and move it out so
> basically the only difference should the additional prio++ and
> possibly a failing branch prediction.

But the branch prediction is where I personally think a lot
of the lossage is coming from.  These can cost upwards of 20
or 30 processor cycles, easily.  That's getting close to the
cost of a L2 cache miss.

I see the difficulties with this change now, why don't we revisit
this some time in the future?

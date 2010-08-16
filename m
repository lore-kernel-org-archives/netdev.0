From: David Miller <davem@davemloft.net>
Subject: Re: [LOCKDEP BUG][2.6.36-rc1] xt_info_wrlock?
Date: Mon, 16 Aug 2010 12:44:00 -0700 (PDT)
Message-ID: <20100816.124400.42792595.davem@davemloft.net>
References: <1281978469.3268.55.camel@gandalf.stny.rr.com>
	<1281979893.2524.54.camel@edumazet-laptop>
	<1281981301.3268.110.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net, mingo@elte.hu,
	peterz@infradead.org
To: rostedt@goodmis.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281981301.3268.110.camel@gandalf.stny.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Rostedt <rostedt@goodmis.org>
Date: Mon, 16 Aug 2010 13:55:01 -0400

> Please tell me what prevents an interrupt going off after we grab the
> xt_info_wrlock(cpu) in get_counters().

He's only accessing the per-cpu counter locks of other cpus.

The per-cpu lock is only locally accessed by a cpu in software
interrupt context.

That is why his transformation is legal.

Lockdep simply hasn't been informed of this invariant and has
to assume the worst.

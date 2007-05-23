From: Ingo Molnar <mingo@elte.hu>
Subject: Re: bad networking related lag in v2.6.22-rc2
Date: Wed, 23 May 2007 13:05:56 +0200
Message-ID: <20070523110556.GA8653@elte.hu>
References: <20070517174533.GA538@elte.hu> <200705221147.56571.kernel@prachanda.hub> <20070522062233.GA20002@elte.hu> <200705231110.44526.kernel@prachanda.hub> <20070523063052.GB26814@elte.hu> <46541DC4.4090501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anant Nitya <kernel@prachanda.info>, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:56080 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758730AbXEWLGd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 07:06:33 -0400
Content-Disposition: inline
In-Reply-To: <46541DC4.4090501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Patrick McHardy <kaber@trash.net> wrote:

> How is this trace to be understood? Is it simply a call trace in 
> execution-order? [...]

yeah. There's a help section at the top of the trace which explains the 
other fields too:

                 _------=> CPU#
                / _-----=> irqs-off
               | / _----=> need-resched
               || / _---=> hardirq/softirq
               ||| / _--=> preempt-depth
               |||| /
               |||||     delay
   cmd     pid ||||| time  |   caller
      \   /    |||||   \   |   /
 privoxy-12926 1.Ns1    0us : ktime_get_ts (ktime_get)

the function name in braces is the parent function. So in this case the 
trace entry means we called ktime_get_ts() from ktime_get().

	Ingo

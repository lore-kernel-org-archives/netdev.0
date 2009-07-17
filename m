From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 1/3] net: serialize hrtimer callback in sched_cbq
Date: Fri, 17 Jul 2009 08:44:30 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0907170838091.13838@localhost.localdomain>
References: <20090709215606.526259917@linutronix.de>  <20090712.135555.207096388.davem@davemloft.net>  <alpine.LFD.2.00.0907141040350.2777@localhost.localdomain>  <20090714.090055.56906831.davem@davemloft.net>  <1247588890.7500.186.camel@twins>
 <alpine.LFD.2.01.0907140940440.13838@localhost.localdomain> <1247832892.15751.35.camel@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, tglx@linutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964843AbZGQPo7@vger.kernel.org>
In-Reply-To: <1247832892.15751.35.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Jul 2009, Peter Zijlstra wrote:
> 
> How would something like the below work for people?

This looks saner.

It was the insanity of having the core timer code know about different 
modes that caused all the sily problems.

Having a separate abstraction layer for "I want to get a softirq timeout" 
sounds fine, as long as the timer code itself never cares.

That said, I don't think this shoud be a "hrtimer" issue (reflected in 
your naming and include file choice). I think this is a softirq or tasklet 
(or whatever) issue, and should be named that way.

Why should the timer code (and header files) care about how you can use 
tasklets with them? It shouldn't. The timers should be seen as the really 
low-level critical code, and the timer code should never need to know 
about softirq's or tasklets or whatever.

So I think you shouldmove it to kernel/softirq.c.

			Linus

From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 1/3] net: serialize hrtimer callback in sched_cbq
Date: Tue, 14 Jul 2009 09:42:14 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0907140940440.13838@localhost.localdomain>
References: <20090709215606.526259917@linutronix.de>  <20090712.135555.207096388.davem@davemloft.net>  <alpine.LFD.2.00.0907141040350.2777@localhost.localdomain>  <20090714.090055.56906831.davem@davemloft.net> <1247588890.7500.186.camel@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, tglx@linutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kaber@trash.net
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755542AbZGNQmw@vger.kernel.org>
In-Reply-To: <1247588890.7500.186.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 14 Jul 2009, Peter Zijlstra wrote:
> 
> Linus really hated the softirq mode, which is what prompted me to change
> that.
> 
> Now, it might be he only hated the particular interface and the
> resulting code, but I think to remember he simply thought the whole
> thing daft.

Yes. And I hated the bugs it had. 

Don't make something as core as timers any more complicated. Don't take 
locks in timers and then complain about deadlocks. If your locking is 
broken, don't make the core timers be idiotically broken.

Because it was. The code was a total mess to follow, and had bugs.

		Linus

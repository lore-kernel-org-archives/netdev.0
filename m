From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fix boot-time hangs from PREEMPT_RCU and NO_HZ
Date: Thu, 28 Feb 2008 21:01:40 -0800
Message-ID: <20080228210140.37abe9cd.akpm@linux-foundation.org>
References: <Pine.LNX.4.58.0801291113350.20371@gandalf.stny.rr.com>
	<20080229044329.GA20207@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	john stultz <johnstul@us.ibm.com>, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:56849 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755982AbYB2FCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 00:02:21 -0500
In-Reply-To: <20080229044329.GA20207@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Feb 2008 20:43:29 -0800 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> This is a repost of http://lkml.org/lkml/2008/2/2/11.  It is needed in
> 2.6.25 in order to prevent boot-time hangs when running with PREEMPT_RCU
> and NO_HZ.
> 
> Preemptible RCU can get stuck if a CPU goes idle and NO_HZ is set. The
> idle CPU will not progress the RCU through its grace period, so that
> any subsequent synchronize_rcu() invocations can hang until such time
> as a process starts running on the idle CPU.  If no such process runs,
> subsequent synchronize_rcu() invocations will hang indefinitely, in turn
> hanging the system.  Without this patch, one of Steve Rostedt's boxes
> hangs on boot when PREEMPT_RCU and NO_HZ are set. That same box boots
> fine with this patch.
> 
> Note: This patch came directly from the -rt patch where it has been tested
> for several months.
> 
> Andrew, could you please apply this?

I already have it, via git-sched.  Presumably Ingo has it lined up for the
next sched-related merge.

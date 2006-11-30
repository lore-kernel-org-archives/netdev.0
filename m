From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Bug 7596 - Potential performance bottleneck for Linxu TCP
Date: Thu, 30 Nov 2006 07:32:52 +0100
Message-ID: <20061130063252.GC2003@elte.hu>
References: <HNEBLGGMEGLPMPPDOPMGKEAJCGAA.wenji@fnal.gov> <20061129154200.c4db558c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wenji@fnal.gov, netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:58053 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S1757861AbWK3GfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 01:35:06 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061129154200.c4db558c.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Andrew Morton <akpm@osdl.org> wrote:

> > Attached is the detailed description of the problem and one possible 
> > solution.
> 
> Thanks.  The attachment will be too large for the mailing-list servers 
> so I uploaded a copy to 
> http://userweb.kernel.org/~akpm/Linux-TCP-Bottleneck-Analysis-Report.pdf
> 
> From a quick peek it appears that you're getting around 10% 
> improvement in TCP throughput, best case.

Wenji, have you tried to renice the receiving task (to say nice -20) and 
see how much TCP throughput you get in "background load of 10.0". 
(similarly, you could also renice the background load tasks to nice +19 
and/or set their scheduling policy to SCHED_BATCH)

as far as i can see, the numbers in the paper and the patch prove the 
following two points:

 - a task doing TCP receive with 10 other tasks running on the CPU will
   see lower TCP throughput than if it had the CPU for itself alone.

 - a patch that tweaks the scheduler to give the receiving task more
   timeslices (i.e. raises its nice level in essence) results in ...
   more timeslices, which results in higher receive numbers ...

so the most important thing to check would be, before any scheduler and 
TCP code change is considered: if you give the task higher priority 
/explicitly/, via nice -20, do the numbers improve? Similarly, if all 
the other "background load" tasks are reniced to nice +19 (or their 
policy is set to SCHED_BATCH), do you get a similar improvement?

	Ingo

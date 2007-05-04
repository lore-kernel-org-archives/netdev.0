From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Strange soft lockup detected message (looks like spin_lock bug in pcnet32)
Date: Fri, 4 May 2007 15:02:36 -0400
Message-ID: <20070504190236.GE8753@csclub.uwaterloo.ca>
References: <20070503203143.GA8753@csclub.uwaterloo.ca> <20070504141024.GB8753@csclub.uwaterloo.ca> <20070504143326.GD24769@slug> <20070504151934.GA8754@csclub.uwaterloo.ca> <20070504153438.GE24769@slug> <20070504154009.GE8751@csclub.uwaterloo.ca> <20070504174456.GC8753@csclub.uwaterloo.ca> <20070504175017.GD8753@csclub.uwaterloo.ca> <20070504182433.GA11595@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frederik Deweerdt <deweerdt@free.fr>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Don Fry <pcnet32@verizon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:46102 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755364AbXEDTCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 15:02:37 -0400
Content-Disposition: inline
In-Reply-To: <20070504182433.GA11595@verizon.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 04, 2007 at 11:24:33AM -0700, Don Fry wrote:
> All instances of obtaining the lock in pcnet32 are done as
> spin_lock_irqsave except the interrupt handler itself.  The interrupt mask
> needs to be saved everywhere else, but the interrupt handler is known not
> to need to save the flags.
> 
> If the lock is held and the same CPU tries to get the lock again, it will
> wait a very long time ;-(.  I believe the locking is fine for a
> non-preemptable kernel, but I have little experience with a preemptable
> kernel.
> 
> When does a preemptable kernel allow interrupts to occur?

I have no idea actually.

> Is there a bug in this particular architectures locking code?

On i386?  I hope not.

> From looking at preempt-locking.txt the driver has (1) no per-cpu data,
> (2) 'CPU state protection' should be fine,
> (3) the 'lock is acquired and released by the same task'.
> I don't see a problem unless I am misunderstanding something.

Well I don't know, but something is going wrong and causing the soft
lock up.  I must admit I am surprised if an interrupt can occour while
handling an interrupt, but then again maybe that is supposed to be
allowed.

--
Len Sorensen

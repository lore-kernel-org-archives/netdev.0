From: Don Fry <pcnet32@verizon.net>
Subject: Re: Strange soft lockup detected message (looks like spin_lock bug in pcnet32)
Date: Fri, 4 May 2007 11:24:33 -0700
Message-ID: <20070504182433.GA11595@verizon.net>
References: <20070503203143.GA8753@csclub.uwaterloo.ca> <20070504141024.GB8753@csclub.uwaterloo.ca> <20070504143326.GD24769@slug> <20070504151934.GA8754@csclub.uwaterloo.ca> <20070504153438.GE24769@slug> <20070504154009.GE8751@csclub.uwaterloo.ca> <20070504174456.GC8753@csclub.uwaterloo.ca> <20070504175017.GD8753@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frederik Deweerdt <deweerdt@free.fr>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [71.117.224.81] ([71.117.224.81]:22090 "EHLO linux.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161605AbXEDSzY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 14:55:24 -0400
Content-Disposition: inline
In-Reply-To: <20070504175017.GD8753@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All instances of obtaining the lock in pcnet32 are done as
spin_lock_irqsave except the interrupt handler itself.  The interrupt mask
needs to be saved everywhere else, but the interrupt handler is known not
to need to save the flags.

If the lock is held and the same CPU tries to get the lock again, it will
wait a very long time ;-(.  I believe the locking is fine for a
non-preemptable kernel, but I have little experience with a preemptable
kernel.

When does a preemptable kernel allow interrupts to occur?
Is there a bug in this particular architectures locking code?
>From looking at preempt-locking.txt the driver has (1) no per-cpu data,
(2) 'CPU state protection' should be fine,
(3) the 'lock is acquired and released by the same task'.
I don't see a problem unless I am misunderstanding something.

Don
